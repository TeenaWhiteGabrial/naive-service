import { Context, Next } from "koa"
import AiService from '../services/ai'

class AiController {
    private service: AiService = new AiService()
    /** 获取名人名言 */
    getVerse = async (ctx: Context, next: Next) => {
        const { author } = ctx.request.body
        const res = await this.service.getVerse(author)
        ctx.body = res
        return next()
    };
}

export default new AiController();