import { Context, Next } from "koa"
import UserService from '../services/user'

class UserController {
    private service: UserService = new UserService()
    addUser = async (ctx: Context, next: Next) => {
        const data = ctx.request.body
        const res = await this.service.insertUser(data)
        ctx.body = res
        return next()
    }
    deleteUser = async (ctx: Context, next: Next) => {
        const userId = ctx.params.userId

        ctx.body = await this.service.deleteUser(userId)
        return next()
    }
    updateUser = async (ctx: Context, next: Next) => {
        const userId = ctx.params.userid
        const data = ctx.request.body
        const res = await this.service.updateUser(userId, data)
        ctx.body = res
        return next()
    }
    getSimpleUser = async (ctx: Context, next: Next) => {
        const res = await this.service.getSimpleUserInfo(ctx.userId)
        ctx.body = res
        return next()
    }
    getAllUser = async (ctx: Context, next: Next) => {
        const res = await this.service.getAllUserInfo(ctx.userId)
        ctx.body = res
        return next()
    }

    getUserList = async (ctx: Context, next: Next) => {
        const { param, pageNo, pageSize } = ctx.request.body
        const { list, count } = await this.service.getUserList(param, pageNo, pageSize)

        ctx.body = {
            pageData: list,
            total: count
        }
        return next()
    }
    /** 获取菜单 */
    getMenus = async (ctx: Context, next: Next) => {
        const userinfo = await this.service.getAllUserInfo(ctx.userId)

        ctx.body = await this.service.getMenus(userinfo?.role)
        return next()
    }
    /** 自己修改密码，需要验证原密码 */
    changePassword = async (ctx: Context, next: Next) => {
        const userId = ctx.userId
        const { oldPassword, newPassword } = ctx.request.body
        const res = await this.service.changePassword(userId, oldPassword, newPassword)
        ctx.body = res
        return next()
    }
    /** 重置他人密码，需要验证权限 */
    resetPassword = async (ctx: Context, next: Next) => {
        const currentUserId = ctx.userId
        const { userId, password } = ctx.request.body
        const res = await this.service.resetPassword(currentUserId, userId, password)
        ctx.body = res
        return next()
    }

    /** 获取角色列表 */
    getRoleList = async (ctx: Context, next: Next) => {
        const { params } = ctx.request.body
        const res = await this.service.getRoleList(params)
        ctx.body = res
        return next()
    }
    /** 新建角色 */
    addRole = async (ctx: Context, next: Next) => {
        const { code, name } = ctx.request.body
        const res = await this.service.addRole(code, name)
        ctx.body = res
        return next()
    }
    /** 修改角色 */
    updateRole = async (ctx: Context, next: Next) => {
        const { code, name } = ctx.request.body
        const res = await this.service.updateRole(code, name)
        ctx.body = res
        return next()
    }

    /** 删除角色 */
    deleteRole = async (ctx: Context, next: Next) => {
        const roleCode = ctx.params.roleCode
        const res = await this.service.deleteRole(roleCode)
        ctx.body = res
        return next()
    }

    /** 获取权限菜单 */
    getMenuTree = async (ctx: Context, next: Next) => {
        const res = await this.service.getMenuTree()
        ctx.body = res
        return next()
    }

    /** 获取按钮列表 */
    getButtons = async (ctx: Context, next: Next) => {
        const res = await this.service.getButtons()
        ctx.body = res
        return next()
    }

    /** 增加权限菜单 */
    addPermission = async (ctx: Context, next: Next) => {
        const res = await this.service.addPermission()
        ctx.body = res
        return next()
    }

    /** 修改权限菜单 */
    updatePermission = async (ctx: Context, next: Next) => {
        const res = await this.service.updatePermission()
        ctx.body = res
        return next()
    }

    /** 删除权限菜单 */
    deletePermission = async (ctx: Context, next: Next) => {
        const res = await this.service.deletePermission()
        ctx.body = res
        return next()
    }
}

export default new UserController();