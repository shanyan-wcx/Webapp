import { webview } from '@kit.ArkWeb';
import createItemBuilder from './Dialog';
import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';

const PAD_USER_AGENT: string =
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTMl, like Gecko) Chrome/99.0.4844.88 Safari/537.36'
const PHONE_USER_AGENT: string =
  'Mozilla/5.0 (Linux; Android 10.0; ohos) AppleWebKit/537.36 (KHTMl, like Gecko) Chrome/99.0.4844.88 HuaweiBrowser/13.0.4.302 Mobile Safari/537.36'

export interface Item {
  icon: string;
  name: string;
  url: string;
  title?: string;
  index?: number;
}

PersistentStorage.persistProp('items', []);

@Entry
@Component
struct Index {
  @State mainWindow: window.Window | null = null
  @State displayWidth: number = 0
  @State displayHeight: number = 0
  @State useragent: string = PHONE_USER_AGENT
  @StorageLink('items') items: Item[] = []
  @State url: string = ''
  @State showPage: boolean = false
  @State showProgress: boolean = false
  @State item: Item = {
    icon: '',
    name: '',
    url: ''
  }
  controller: webview.WebviewController = new webview.WebviewController();
  createItem: CustomDialogController = new CustomDialogController({
    builder: createItemBuilder(this.item),
    width: 340,
    height: 310
  })

  async aboutToAppear() {
    this.mainWindow = await window.getLastWindow(getContext(this))
    this.displayWidth = px2vp(this.mainWindow.getWindowProperties().windowRect.width)
    this.displayHeight = px2vp(this.mainWindow.getWindowProperties().windowRect.height)
    if (this.displayWidth / this.displayHeight > 2 / 3 && this.displayHeight > 700) {
      this.useragent = PAD_USER_AGENT
    } else {
      this.useragent = PHONE_USER_AGENT
    }
  }

  onBackPress(): boolean | void {
    if (this.showPage === true && this.controller.accessBackward() === true) {
      this.controller.backward()
      return true
    } else if (this.showPage === true && this.controller.accessBackward() === false) {
      this.showPage = false
      return true
    } else {
      return false
    }
  }

  @Builder
  itemEnd(index: number, item: Item) {
    Row() {
      Button({ type: ButtonType.Circle }) {
        Image($rawfile('edit.png'))
          .width(35)
          .height(35)
      }
      .width(50)
      .height(50)
      .margin({ left: 10 })
      .backgroundColor(Color.Blue)
      .onClick(() => {
        this.item = item
        this.item.title = '编辑'
        this.item.index = index
        this.createItem.open()
      })

      Button({ type: ButtonType.Circle }) {
        Image($rawfile('delete.png'))
          .width(35)
          .height(35)
      }
      .width(50)
      .height(50)
      .margin({ left: 10 })
      .backgroundColor(Color.Red)
      .onClick(() => {
        this.items.splice(index, 1);
      })
    }
    .width(120)
  }

  build() {
    if (this.showPage === false) {
      Column() {
        if (this.items.length > 0) {
          List() {
            ForEach(this.items, (item: Item, index) => {
              ListItem() {
                Row() {
                  Image(item.icon)
                    .alt($rawfile('alt.jpg'))
                    .width(60)
                    .height(60)
                    .borderRadius(10)
                  Text(item.name)
                    .width('100%')
                    .layoutWeight(1)
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .margin({ left: 10 })
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .width('100%')
                .height(80)
                .borderRadius(10)
                .padding({ left: 10, right: 10 })
                .backgroundColor('#E9E9E9')
                .onClick(() => {
                  this.url = item.url
                  this.showPage = true
                })
              }
              .margin({ top: 20 })
              .borderRadius(10)
              .clip(true)
              .swipeAction({
                end: {
                  builder: () => {
                    this.itemEnd(index, item)
                  },
                }
              })
            })
          }
          .width('100%')
          .height('100%')
          .layoutWeight(1)
          .margin({ bottom: 20 })
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Fade)
        } else {
          Column() {
            Text("没有项目")
              .fontSize(40)
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .height('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }

        Button() {
          Text("添加")
            .fontSize(20)
        }
        .width('100%')
        .height(60)
        .backgroundColor('#E9E9E9')
        .onClick(() => {
          this.item = {
            icon: '',
            name: '',
            url: '',
            title: '新建'
          }
          this.createItem.open()
        })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 20, right: 20 })
    } else {
      Stack() {
        Web({ src: this.url, controller: this.controller })
          .zoomAccess(false)
          .mediaPlayGestureAccess(false)
          .horizontalScrollBarAccess(false)
          .verticalScrollBarAccess(false)
          .fileAccess(true)
          .domStorageAccess(true)
          .databaseAccess(true)
          .javaScriptAccess(true)
          .onControllerAttached(() => {
            try {
              let userAgent = this.controller.getUserAgent() + this.useragent;
              this.controller.setCustomUserAgent(userAgent);
            } catch (error) {
              console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
            }
          })
          .onPageBegin(() => {
            this.showProgress = true
          })
          .onPageEnd(() => {
            this.showProgress = false
          })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

        Column() {
          LoadingProgress()
            .width(80)
            .height(80)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .visibility(this.showProgress === true ? Visibility.Visible : Visibility.None)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
  }
}