module.exports = cds.service.impl(async function () {

    const { EmployeeSet, PurchaseOrderSet, PurchaseOrderItemSet } = this.entities;

    const STATUS_TEXT = { A: 'Approved', P: 'Pending', R: 'Rejected' };
    const STATUS_CRITICALITY = { A: 3, P: 2, R: 1 };

    // NEW: confirmed present in module scope this time — returns only real,
    // persisted, non-virtual, non-to-many columns for a given entity.
    function persistedColumns(entity) {
        const cols = Object.keys(entity.elements).filter(name => {
            // CHANGED: exclude CAP-generated draft-framework elements by name —
            // these appear in entity.elements but aren't selectable as plain columns
            if (name === 'SiblingEntity') return false;
            if (name === 'DraftAdministrativeData') return false;   // CHANGED — keep _DraftUUID, drop the bare association

            const el = entity.elements[name];
            if (el.virtual) return false;
            if (el.value !== undefined) return false;
            if (el['@Core.Computed']) return false;
            if (el.type === 'cds.Composition') return false;
            if (el.type === 'cds.Association' && el.cardinality?.max === '*') return false;
            if (el.is2many) return false;
            return true;
        });

        //console.log(`[copyPurchaseOrder] persistedColumns(${entity.name}):`, cols);
        return cols;
    }


    // NEW: computes the next PO number as (max existing numeric suffix, across
    // both active AND draft PurchaseOrderSet rows) + 1, preserving zero-padding.
    // Assumes PO_ID format like "PO-9022".
    async function getNextPOId(tx, PurchaseOrderSet) {
        const PO_ID_PATTERN = /^PO-(\d+)$/;

        const [activeRows, draftRows] = await Promise.all([
            tx.run(SELECT.from(PurchaseOrderSet).columns('PO_ID')),
            tx.run(SELECT.from(PurchaseOrderSet.drafts).columns('PO_ID'))
        ]);

        let maxNum = 0;
        let digitWidth = 4; // fallback width if no existing PO matches the pattern

        for (const row of [...activeRows, ...draftRows]) {
            const match = row.PO_ID && row.PO_ID.match(PO_ID_PATTERN);
            if (!match) continue;
            const num = parseInt(match[1], 10);
            if (num > maxNum) {
                maxNum = num;
                digitWidth = match[1].length;
            }
        }

        const nextNum = maxNum + 1;
        return `PO-${String(nextNum).padStart(digitWidth, '0')}`;
    }

    // Ensure OVERALL_STATUS is always fetched, even if the UI's $select omits it
    this.before('READ', PurchaseOrderSet, (req) => {
        const cols = req.query.SELECT?.columns;
        if (cols && !cols.some(c => c.ref?.[0] === 'OVERALL_STATUS')) {
            cols.push({ ref: ['OVERALL_STATUS'] });
        }
    });

    // Populate the calculated columns after every read of PurchaseOrderSet
    this.after('READ', PurchaseOrderSet, (results) => {
        const rows = Array.isArray(results) ? results : [results];
        rows.forEach(r => {
            if (!r || !r.OVERALL_STATUS) return;
            r.OverallStatusText = STATUS_TEXT[r.OVERALL_STATUS] ?? null;
            r.StatusCriticality = STATUS_CRITICALITY[r.OVERALL_STATUS] ?? 0;
        });
    });

    //Validation logic for EmployeeSet before CREATE and UPDATE operations
    this.before(['CREATE', 'UPDATE'], EmployeeSet, async (req, res) => {
        console.log('Before Create/Update EmployeeSet:', req.data.salaryAmount);
        const { data } = req;
        if (data.salaryAmount > 1000000) {
            req.error(500, 'Salary amount is too high :)');
        }
    });

    ///Implemementation of the non-instance bound function
    this.on('getMostExpensiveOrder', async (req, res) => {

        try {
            const tx = cds.tx(req);
            const myData = await tx.read(PurchaseOrderSet).orderBy({
                "GROSS_AMOUNT": "desc"
            }).limit(1);
            return myData;

        } catch (error) {
            return req.error(500, 'Error fetching the most expensive order: ' + error.message);

        }
        //const db = await cds.connect.to('db');
        //const result = await db.run(SELECT.from('myCapApp.db.PurchaseOrderSet').orderBy('totalAmount desc').limit(1));
        //return result[0];
    });

    ///Implemementation of the non-instance bound function Default PO Status during Creation
    this.on('getOrderDefaultStatus', async (req, res) => {

        try {
            return { OVERALL_STATUS: 'P' };

        } catch (error) {
            return req.error(500, 'Error fetching order: ' + error.message);

        }
    });

    ///Implement the action to boost the product amount
    this.on('boost', PurchaseOrderSet, async (req, res) => {
        //Programatically check @ runtime if the user has the 'Editor' permission, if not return 403 error
        req.user.is('Editor') || req.error(403, 'You are not authorized to boost the purchase order');

        const { NODE_KEY } = req.params[0]; // Assuming the ID is passed as a parameter
        const tx = cds.tx(req);
        try {
            // Fetch the current order
            const order = await tx.read(PurchaseOrderSet).where({ NODE_KEY }).limit(1);
            if (!order.length) {
                return req.error(404, 'Purchase Order not found');
            }

            // Increase the amount by 10%
            const newAmount = order[0].GROSS_AMOUNT * 2;

            // Update the order with the new amount
            await tx.update(PurchaseOrderSet).set({ GROSS_AMOUNT: newAmount }).where({ NODE_KEY });

            // Return the updated order
            const updatedOrder = await tx.read(PurchaseOrderSet).where({ NODE_KEY }).limit(1);
            return updatedOrder[0];

        } catch (error) {
            return req.error(500, 'Error boosting the purchase order: ' + error.message);
        }
    });

    ///Implement the action to Set Staus Approved
    this.on('setApproved', PurchaseOrderSet, async (req) => {

        //req.user.is('Editor') ||
        //    req.error(403, 'You are not authorized to approve the purchase order');

        const { NODE_KEY } = req.params[0];

        const tx = cds.transaction(req);

        const order = await tx.run(
            SELECT.one.from(PurchaseOrderSet).where({ NODE_KEY })
        );

        if (!order) {
            return req.error(404, 'Purchase Order not found');
        }

        await tx.run(
            UPDATE(PurchaseOrderSet)
                .set({ OVERALL_STATUS: 'A' })
                .where({ NODE_KEY })
        );

        return tx.run(
            SELECT.one.from(PurchaseOrderSet).where({ NODE_KEY })
        );
    });


    // Implement the action to copy a Purchase Order and its Items
    this.on('copyPurchaseOrder', PurchaseOrderSet, async (req) => {
        try {
            const { NODE_KEY } = req.params[0];
            const tx = cds.tx(req);

            const poCols = persistedColumns(PurchaseOrderSet);
            const itemCols = persistedColumns(PurchaseOrderItemSet);

            //console.log('[copyPurchaseOrder] STEP 1: reading originalPO');
            const originalPO = await tx.run(
                SELECT.one.from(PurchaseOrderSet)
                    .columns(poCols)
                    .where({ NODE_KEY })
            );
            //console.log('[copyPurchaseOrder] STEP 1 OK');

            if (!originalPO) return req.error(404, 'Purchase Order not found');

            //console.log('[copyPurchaseOrder] STEP 2: reading originalItems');
            const originalItems = await tx.run(
                SELECT.from(PurchaseOrderItemSet)
                    .columns(itemCols)
                    .where({ PARENT_KEY_NODE_KEY: NODE_KEY })
            );
            //console.log('[copyPurchaseOrder] STEP 2 OK');

            const newKey = cds.utils.uuid().replace(/-/g, '').toUpperCase();
            const draftAdminUUID = cds.utils.uuid();
            const now = new Date().toISOString();
            const user = req.user.id || 'anonymous';

            // NEW: compute next PO_ID as max(active + draft) + 1
            console.log('[copyPurchaseOrder] STEP 2b: computing next PO_ID');
            const newPOId = await getNextPOId(tx, PurchaseOrderSet);
            console.log('[copyPurchaseOrder] STEP 2b OK, newPOId =', newPOId);

            await tx.run(
                INSERT.into('DRAFT.DraftAdministrativeData').entries({
                    DraftUUID: draftAdminUUID,
                    CreationDateTime: now,
                    CreatedByUser: user,
                    DraftIsCreatedByMe: true,
                    LastChangeDateTime: now,
                    LastChangedByUser: user,
                    InProcessByUser: user,
                    DraftIsProcessedByMe: true
                })
            );

            // Strip fields that must not be copied, keep everything else
            const {
                NODE_KEY: _oldKey,
                IsActiveEntity,
                HasActiveEntity,
                HasDraftEntity,
                DraftAdministrativeData_DraftUUID,
                OverallStatusText,
                StatusCriticality,
                ...poData
            } = originalPO;

            const newDraftPO = {
                ...poData,
                NODE_KEY: newKey,
                // PO_ID: `${poData.PO_ID}-COPY-${Date.now()}`,
                PO_ID: newPOId,
                OVERALL_STATUS: 'P',
                IsActiveEntity: false,
                HasActiveEntity: false,
                HasDraftEntity: false,
                DraftAdministrativeData_DraftUUID: draftAdminUUID
            };

            //console.log('[copyPurchaseOrder] STEP 3: inserting header draft');
            await tx.run(INSERT.into(PurchaseOrderSet.drafts).entries(newDraftPO));
            //console.log('[copyPurchaseOrder] STEP 3 OK');

            if (originalItems && originalItems.length > 0) {
                const draftItems = originalItems.map(item => {
                    const {
                        NODE_KEY: _itemKey,
                        PARENT_KEY_NODE_KEY,
                        IsActiveEntity,
                        HasActiveEntity,
                        HasDraftEntity,
                        DraftAdministrativeData_DraftUUID,
                        ...itemData
                    } = item;

                    return {
                        ...itemData,
                        NODE_KEY: cds.utils.uuid().replace(/-/g, '').toUpperCase(),
                        PARENT_KEY_NODE_KEY: newKey,
                        IsActiveEntity: false,
                        HasActiveEntity: false,
                        HasDraftEntity: false,
                        DraftAdministrativeData_DraftUUID: draftAdminUUID
                    };
                });

                //console.log('[copyPurchaseOrder] STEP 4: inserting item drafts');
                await tx.run(INSERT.into(PurchaseOrderItemSet.drafts).entries(draftItems));
                //console.log('[copyPurchaseOrder] STEP 4 OK');
            }

            //console.log('[copyPurchaseOrder] STEP 5: final draft select');
            // CHANGED: compute columns from PurchaseOrderSet.drafts itself, not PurchaseOrderSet
            const poDraftCols = persistedColumns(PurchaseOrderSet.drafts);

            const result = await tx.run(
                SELECT.one.from(PurchaseOrderSet.drafts)
                    .columns(poDraftCols)                      // CHANGED
                    .where({ NODE_KEY: newKey })
            );
            //console.log('[copyPurchaseOrder] STEP 5 OK');
            return result;

        } catch (error) {
            return req.error(500, 'Error copying purchase order: ' + error.message);
        }
    });
    ///Implement the action to copy a Purchase Order and its Items
    // this.on('copyPurchaseOrder', PurchaseOrderSet, async (req) => {

    //     const { NODE_KEY } = req.params[0];
    //     const tx = cds.tx(req);

    //     // 1. Read the original PO together with its Items
    //     const original = await tx.run(
    //         SELECT.one.from(PurchaseOrderSet)
    //             .columns(po => { po('*'), po.Items(i => i('*')) })
    //             .where({ NODE_KEY })
    //     );

    //     if (!original) {
    //         return req.error(404, 'Purchase Order not found');
    //     }

    //     // 2. Generate a fresh key for the new PO (32-char hex, matching commons.Guid)
    //     const newKey = cds.utils.uuid().replace(/-/g, '').toUpperCase();

    //     // 3. Strip out fields that must not be copied as-is
    //     const {
    //         NODE_KEY: _oldKey,
    //         Items,
    //         IsActiveEntity,
    //         HasActiveEntity,
    //         HasDraftEntity,
    //         DraftAdministrativeData,
    //         OverallStatusText,
    //         StatusCriticality,
    //         ...poData
    //     } = original;

    //     // 4. Build the new PO, resetting status and giving items new keys
    //     const newPO = {
    //         ...poData,
    //         NODE_KEY: newKey,
    //         PO_ID: poData.PO_ID + '-COPY',
    //         OVERALL_STATUS: 'P', // reset to Pending regardless of original status
    //         Items: (Items || []).map(item => {
    //             const { NODE_KEY: _itemKey, PARENT_KEY_NODE_KEY, ...itemData } = item;
    //             return {
    //                 ...itemData,
    //                 NODE_KEY: cds.utils.uuid().replace(/-/g, '').toUpperCase()
    //             };
    //         })
    //     };

    //     // 5. Create the new PO (with its items, via deep insert)
    //     await tx.create(PurchaseOrderSet).entries(newPO);

    //     // 6. Return the newly created PO
    //     return tx.run(
    //         SELECT.one.from(PurchaseOrderSet).where({ NODE_KEY: newKey })
    //     );
    // });

});

