import { Context, Next } from "koa"
import SiteService from '../services/site'

class UserController {
    private service: SiteService = new SiteService()
    getSite = async (ctx: Context, next: Next) => {
        const host = 'localhost:3000'
        const res = await this.service.getSiteInfo(host)
        ctx.body = res
        return next()
    }
}

export default new UserController();