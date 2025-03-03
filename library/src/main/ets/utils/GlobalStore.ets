import window from '@ohos.window';
import font from '@ohos.font';
import { getWindowAvoidSize } from './utils';
import { bundleManager, common } from '@kit.AbilityKit';
import { IBestGlobalConfig, IBestGlobalConfigType } from '../model/Global.type';
import { setIBestUIBaseStyle } from '../theme-chalk/src';
import { display } from '@kit.ArkUI';

// 全局存储中心
export default class GlobalStore {
	// windowStage
	public static windowStage: window.WindowStage
	// context
	public static context: common.UIAbilityContext
	// 顶部规避尺寸
	public static topAvoidHeight: number = 0
	// 底部导航条高度
	public static bottomBarHeight: number = 0
	// 屏幕信息
	public static screenWidth: number = 0
	public static screenHeight: number = 0
	/**
	 * 初始化
	 */
	public static init(windowStage: window.WindowStage, context: common.UIAbilityContext){
		GlobalStore.windowStage = windowStage
		GlobalStore.context = context
		// 获取顶部和底部规避尺寸
		GlobalStore.getAvoidSize()
		// 获取屏幕尺寸
		GlobalStore.getScreenSize()
		// 获取是否是应用
		GlobalStore.getBundleType()
		// 设置旋转监听
		GlobalStore.screenRotateListener()
		// 监听颜色模式变化
		GlobalStore.setColorModeListener()
		// 注册字体
		font.registerFont({
			familyName: 'ibestFont',
			familySrc: $rawfile('vant_font.woff')
		})
	}
	/**
	 * 获取规避尺寸
     */
	private static getAvoidSize(){
		let res = getWindowAvoidSize()
		GlobalStore.topAvoidHeight = res.topSize
		GlobalStore.bottomBarHeight = res.navigationSize
		AppStorage.setOrCreate("IBestTopAvoidHeight", GlobalStore.topAvoidHeight)
		AppStorage.setOrCreate("IBestBottomBarHeight", GlobalStore.bottomBarHeight)
	}
	/**
	 * 获取屏幕尺寸
     */
	private static getScreenSize(){
		let mainWindow = GlobalStore.windowStage.getMainWindowSync()
		let screenInfo: window.WindowProperties = mainWindow.getWindowProperties()
		let o = display.getDefaultDisplaySync().orientation
		GlobalStore.screenWidth = o == 1 || o == 3 ? screenInfo.windowRect.height : screenInfo.windowRect.width
		GlobalStore.screenHeight = o == 1 || o == 3 ? screenInfo.windowRect.width : screenInfo.windowRect.height
		AppStorage.setOrCreate("IBestIsLandscape", o == 1 || o == 3)
	}
	/**
	 * 监听屏幕旋转
	 */
	private static screenRotateListener() {
		display.on("change", () => {
			setTimeout(() => {
				GlobalStore.getScreenSize()
				GlobalStore.getAvoidSize()
			}, 300)
		})
	}
	/**
	 * 监听颜色模式变化
     */
	private static setColorModeListener(){
		let appContext = GlobalStore.context.getApplicationContext()
		AppStorage.setOrCreate("IBestColorMode", GlobalStore.context.config.colorMode)
		appContext.on('environment', {
			onConfigurationUpdated(config) {
				// 0 深色  1 浅色
				AppStorage.setOrCreate("IBestColorMode", config.colorMode)
			},
			onMemoryLevel() {}
		})
	}
	/**
	 * 获取是否是元服务
	 */
	private static getBundleType(){
		AppStorage.setOrCreate("IBestIsApp", bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).appInfo.bundleType == bundleManager.BundleType.APP)
	}
	/**
	 * 设置全局配置
	 */
	public static setGlobalConfig(option?: IBestGlobalConfigType){
		AppStorage.setOrCreate("IBestGlobalConfig", new IBestGlobalConfig(option))
		setIBestUIBaseStyle()
	}
}