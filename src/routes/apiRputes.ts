import { Router } from 'express';
import { apiController } from '../controllers/apiController'
class ApiRoutes{
    public router: Router = Router();

    constructor(){
        this.config();
    }

    config():void{
     this.router.get('/getIDs', apiController.getIDs  );
    }
}

const apiRoutes = new ApiRoutes();

export default apiRoutes.router;

