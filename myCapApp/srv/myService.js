const cds = require('@sap/cds');
const { Employee } = cds.entities('myCapApp.db.master');

module.exports = (srv) => {
    srv.on('myFunction', async (req, res) => {
        const input = req.data.input;
        // Implement your logic here
        const result = `Hello ${input}`;
        //return result;
        //res.status(200).json({ message: result });
    });

    srv.on('READ', 'EmployeeSet', async(req, res) => {
        //where my grossAmount is greater than 8000
        const results = await cds.tx(req).run(SELECT.from(Employee).where({ "salaryAmount": { '>': 80000 } }));
        return results;
    });
}   