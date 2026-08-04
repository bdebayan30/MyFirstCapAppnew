using {myCapApp.db.master} from '../db/data-model';

//define a service with a function
service myService {
    function myFunction(input: String(80)) returns String;
    entity EmployeeSet as projection on master.Employee;
}
