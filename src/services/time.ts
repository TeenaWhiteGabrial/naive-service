import db from '../utils/pool'

export default class TimeService {

    /** 获取下一个节假日 */
    async getNextHolidayInfo(currentDay:string) {
        const cl = db.collection('holiday-info');
        
        // 查询当前日期的index
        const curDay = await cl.findOne({
            date: currentDay,
        },{
            projection: { index: 1, _id: 0 }
        })

        // 查询条件：日期大于等于当前日期，且stateNum为2
        const query = {
            date: { $gte: currentDay },
            stateNum: "2" // 法定节假日
        }
        // 按日期升序排序，查询第一个
        const nextHoliday = await cl.findOne(query, {
            sort: { date: 1 },
            projection: { date: 1,index:1,stateText:1,_id:0 }
        })
        // 将当前日期转换为整数，计算日期
        const currentDayIndex = parseInt(curDay?.index, 10);
        const diffDays = nextHoliday?.index - currentDayIndex
        
        return {
            holiday: nextHoliday?.stateText,
            days: diffDays
        }
    }

    /** 获取下个周末 */
    async getNextWeekend(){

    }
} 