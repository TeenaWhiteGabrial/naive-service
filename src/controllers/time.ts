import { Context, Next } from "koa"
import TimeServer from '../services/time'

class TimeController {
    private service: TimeServer = new TimeServer()
    /** 获取上传Token */
    getNextHolidayInfo = async (ctx: Context, next: Next) => {
        const date = ctx.params.date
        const res = await this.service.getNextHolidayInfo(date)
        ctx.body = res
        return next()
    };
}

export default new TimeController();