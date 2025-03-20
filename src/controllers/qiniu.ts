import { Context, Next } from "koa"
import QiNiuService from '../services/qiniu'

class QiNiuController {
    private service: QiNiuService = new QiNiuService()
    /** 获取上传Token */
    getUploadToken = async (ctx: Context, next: Next) => {
        const res = await this.service.getUploadToken()
        ctx.body = res
        return next()
    };
}

export default new QiNiuController();