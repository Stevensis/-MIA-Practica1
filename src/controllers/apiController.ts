import { Request, Response} from 'express';
import pool from '../database';

class ApiController {
    public async getIDs(req: Request, res: Response){
         const ids = await pool.query('SELECT * FROM Temportal');
         res.json(ids)
    }
}

export const apiController = new ApiController();