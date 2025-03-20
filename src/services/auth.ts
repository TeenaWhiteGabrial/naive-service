import db from '../utils/pool'
import { CODE } from "../config/code";
import { generatorToken } from "../utils/util";

export default class SiteService {
    /** 查询用户名和密码 */
    async checkCertification(userName: string, password: string) {
        const cl = db.collection('user-info');
        const user = await cl.findOne({
            userName,
            password
        }, {
            projection: { userId: 1 }
        })
        if (user) {
            return {
                token: generatorToken(user.userId)
            }
        } else {
            throw CODE.loginFailer
        }
    }
}