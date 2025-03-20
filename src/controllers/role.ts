import { Context, Next } from "koa"
import AuthService from '../services/auth'

class UserController {
    private service: AuthService = new AuthService()
    /** 验证用户名密码 */
    checkAuth = async (ctx: Context, next: Next) => {
        const { username, password } = ctx.request.body
        const res = await this.service.checkCertification(username, password)
        ctx.body = res
        return next()
    };
    /** 登出 */
    logout = async (ctx: Context, next: Next) => {
        ctx.body = '退出成功'
        return next()
    };

}

export default new UserController();