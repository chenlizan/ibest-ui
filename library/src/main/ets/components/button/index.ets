import { getDefaultBaseStyle, IBEST_UI_NAMESPACE } from '../../theme-chalk/src';
import { COLOR_TYPE, ColorType } from '../../theme-chalk/src/color.type';
import { GRAY_COLOR } from '../../theme-chalk/src/color';
import { CONTAINER_SIZE } from '../../theme-chalk/src/container';
import { IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type';
import { SIZE, SizeType } from '../../theme-chalk/src/size.type';
import { ButtonSizeData } from './index.type';
import { IBestLoading } from '../loading/index';
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils';
import { IBestButtonColor } from './color';
import { IBestIcon } from '../icon';
@Extend(Button)
function btnSizeStyle(data: ButtonSizeData) {
	.padding({
		top: 0,
		right: data.padding,
		bottom: 0,
		left: data.padding
	})
	.height(data.height)
	.width(data.width || 'auto')
}

@Component
export struct IBestButton {
	/**
	 * 全局公共样式
	 */
	@StorageLink(IBEST_UI_NAMESPACE) baseStyle: IBestUIBaseStyleObjType = getDefaultBaseStyle()
	/**
	 * 类型，可选值为 primary success warning danger 默认值为default
	 */
	@Prop type: ColorType = COLOR_TYPE.DEFAULT;
	/**
	 * 大小，可选值为 large normal small mini
	 * size是保留字所以没使用size
	 */
	@Prop buttonSize: SizeType = SIZE.NORMAL;
	/**
	 * 是否为朴素按钮
	 */
	@Prop plain: boolean = false;
	/**
	 * 是否为方形按钮
	 */
	@Prop square: boolean = false;
	/**
	 * 是否为圆形按钮
	 */
	@Prop round: boolean = false;
	/**
	 * 是否使用 0.5px 边框
	 */
	@Prop hairline: boolean = false;
	/**
	 * 是否显示为加载状态
	 */
	@Prop loading: boolean = false;
	/**
	 * loading加载的文案
	 */
	@Prop loadingText: ResourceStr = ""
	/**
	 * 按钮展示的文字
	 */
	@Prop text: ResourceStr
	/**
	 * 是否禁用
	 */
	@Prop disabled: boolean = false;
	/**
	 * 按钮颜色
	 */
	@Prop @Watch('handleColorChange') color: ResourceColor = '';
	/**
	 * 加载图标的大小, 如果为-1就是默认值 默认值跟随字体大小
	 */
	@Prop loadingSize: number | string = -1;
	/**
	 * 按钮宽度
	 */
	@Prop btnWidth?: number | string = undefined;
	/**
	 * 按钮高度
	 */
	@Prop btnHeight?: number | string = undefined;
	/**
	 * 按钮文字大小
	 */
	@Prop btnFontSize?: number | string = undefined;
	/**
	 * 按钮图标
	 * @since 2.0.1
	 */
	@Prop icon: ResourceStr = ""
	/**
	 * 按钮文字颜色
	 * @since 2.0.1
	 */
	@Prop fontColor: ResourceColor = ""
	/**
	 * 按钮边框颜色
	 * @since 2.0.1
	 */
	@Prop btnBorderColor: ResourceColor = ""
	/**
	 * 按钮圆角
	 * @since 2.0.1
	 */
	@Prop btnBorderRadius: number | string = ""
	/**
	 * 图标位置
	 * @since 2.0.3
     */
	@Prop iconPosition: 'left' | 'right' = 'left'
	/**
	 * defaultSlot 默认插槽
	 */
	@BuilderParam defaultBuilder?: CustomBuilder
	/**
	 * 图标的builder
	 */
	@BuilderParam iconBuilder?: CustomBuilder;
	/**
	 * 加载图标的builder
	 */
	@BuilderParam loadingIconBuilder?: CustomBuilder;
	/**
	 * 点击按钮，且按钮状态不为加载或禁用时触发
	 */
	onClickBtn: (event: TouchEvent) => void = () => {}

	@Builder iconContent() {
		if (this.loading) {
			// 如果有自定义loading
			if (this.loadingIconBuilder) {
				this.loadingIconBuilder()
			} else {
				// 默认的loading
				IBestLoading({
					loadingSize: this.getLoadingSize(),
					loadingColor: this.getBtnTextColor()
				}).margin({
					left: this.iconPosition == "right" && this.text ? this.baseStyle.spaceBase : 0,
					right: this.iconPosition == "left" && this.text ? this.baseStyle.spaceBase : 0
				})
			}
			// 加载loading显示的时候不显示图标
		} else if (this.iconBuilder) {
			this.iconBuilder()
		} else if (this.icon) {
			IBestIcon({
				name: this.icon,
				iconSize: this.getBtnSize()?.fontSize,
				color: this.getBtnTextColor()
			}).margin({
				left: this.iconPosition == "right" && this.text ? this.baseStyle.spaceBase : 0,
				right: this.iconPosition == "left" && this.text ? this.baseStyle.spaceBase : 0
			})
		}
	}

	/**
	 * 根据buttonSize换对应的按钮尺寸
	 * 根据size获取按钮的尺寸
	 * 字典形式写起来校验问题很多 改成switch了
	 * @returns
	 */
	getBtnSize() {
		if (this.btnWidth || this.btnHeight) {
			return new ButtonSizeData(this.btnWidth ? 0 : convertDimensionsWidthUnit(15),
				this.btnHeight != undefined ? getSizeByUnit(this.btnHeight) : convertDimensionsWidthUnit(44),
				this.getBtnFontSize() || this.baseStyle.fontSizeMd as string,
				this.btnWidth != undefined ? getSizeByUnit(this.btnWidth) : '')
		}
		const buttonSize = this.buttonSize;
		switch (buttonSize) {
			case SIZE.SMALL:
				return new ButtonSizeData(this.baseStyle.spaceXs as string, convertDimensionsWidthUnit(32),
					this.getBtnFontSize() || this.baseStyle.fontSizeSm as string);
			case SIZE.MINI:
				return new ButtonSizeData(this.baseStyle.spaceBase as string, convertDimensionsWidthUnit(32),
					this.getBtnFontSize() || this.baseStyle.fontSizeXs as string);
			case SIZE.LARGE:
				return new ButtonSizeData(this.baseStyle.spaceXs as string, convertDimensionsWidthUnit(50),
					this.getBtnFontSize() || this.baseStyle.fontSizeLg as string, CONTAINER_SIZE.FULL);
			default:
				return new ButtonSizeData(convertDimensionsWidthUnit(15), convertDimensionsWidthUnit(44),
					this.getBtnFontSize() || this.baseStyle.fontSizeMd as string);
		}
	}
	getBtnFontSize() {
		return this.btnFontSize != undefined ? getSizeByUnit(this.btnFontSize, true) : ""
	}
	/**
	 * 获取按钮的borderRadius
	 * @returns
	 */
	getBtnBorderRadius() {
		return getSizeByUnit(this.btnBorderRadius) ||
			(this.square ? 0 : this.baseStyle[`borderRadius${this.round ? 'Max' : 'Md'}`])
	}
	/**
	 * 获取按钮边框的颜色
	 * @returns
	 */
	getBorderColor() {
		return this.btnBorderColor ||
			(this.color ? this.color : this.type === COLOR_TYPE.DEFAULT ? GRAY_COLOR.GRAY_4 : this.baseStyle[this.type])
	}
	/**
	 * 获取按钮文字的颜色
	 * @returns
	 */
	getBtnTextColor() {
		if (this.fontColor) {
			return this.fontColor
		}
		if (this.plain) {
			return this.color ? this.color :
				this.type === COLOR_TYPE.DEFAULT ? IBestButtonColor.textColor : this.baseStyle[this.type]
		}
		return this.type === COLOR_TYPE.DEFAULT ? IBestButtonColor.textColor : IBestButtonColor.whiteColor
	}
	/**
	 * 根据颜色type获取背景色
	 * @returns
	 */
	getBackgroundColor() {
		return this.plain ? "transparent" :
			this.color ? this.color : this.type == "default" ? IBestButtonColor.defaultBg : this.baseStyle[this.type]
	}
	/**
	 * 获取loading的大小
	 * @returns
	 */
	getLoadingSize() {
		return this.loadingSize != -1 ? getSizeByUnit(this.loadingSize) : this.getBtnSize()?.fontSize as string
	}
	/**
	 * 当传入自定义颜色时 设置type保证颜色渲染正常
	 */
	handleColorChange() {
		if (this.color) {
			this.type = 'primary'
		}
	}
	aboutToAppear() {
		this.handleColorChange()
	}
	build() {
		Button({ type: ButtonType.Normal }) {
			if (this.defaultBuilder) {
				this.defaultBuilder()
			} else {
				Row() {
					if(this.iconPosition == "left"){
						this.iconContent()
					}
					Text(this.loading ? this.loadingText ?? this.text : this.text)
						.fontSize(this.getBtnSize()?.fontSize)
						.fontColor(this.getBtnTextColor())
					if(this.iconPosition == "right"){
						this.iconContent()
					}
				}
			}
		}
		.btnSizeStyle(this.getBtnSize())
		.borderWidth(convertDimensionsWidthUnit(this.hairline ? 0.5 : 1))
		.borderRadius(this.getBtnBorderRadius())
		.fontColor(this.getBtnTextColor())
		.backgroundColor(this.getBackgroundColor())
		.borderColor(this.getBorderColor())
		.hitTestBehavior(this.loading ? HitTestMode.None : HitTestMode.Default)
		.enabled(!this.disabled)
		.opacity(this.disabled && this.plain ? 0.5 : 1)
		.onTouch(event => {
			event.type == TouchType.Up && this.onClickBtn(event)
		})
		.animation({ duration: this.baseStyle.animationDuration as number })
	}
}