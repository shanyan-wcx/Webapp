import { promptAction } from '@kit.ArkUI'
import { Item } from './Index'

@CustomDialog
export default struct createItemBuilder {
  @StorageLink('items') items: Item[] = []
  @State icon: string = ''
  @State name: string = ''
  @State url: string = ''
  @State title: string = ''
  @State index: number = 0
  createItem: CustomDialogController = new CustomDialogController({
    builder: createItemBuilder()
  })

  build() {
    Column() {
      Text(this.title + "项目")
        .width('100%')
        .height(60)
        .textAlign(TextAlign.Center)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      Row() {
        Text("图标")
          .fontSize(20)
          .margin({ top: 5 })
        TextInput({
          placeholder: '项目图标',
          text: $$this.icon
        })
          .width("100%")
          .height(40)
          .layoutWeight(1)
          .borderRadius(15)
          .margin({ left: 15 })
          .fontSize(20)
          .placeholderFont({
            size: 20
          })
          .enterKeyType(EnterKeyType.Next)
      }
      .width('100%')
      .margin({ bottom: 20 })

      Row() {
        Text("名称")
          .fontSize(20)
        TextInput({
          placeholder: '项目名称',
          text: $$this.name
        })
          .width("100%")
          .height(40)
          .layoutWeight(1)
          .borderRadius(15)
          .margin({ left: 15 })
          .fontSize(20)
          .placeholderFont({
            size: 20
          })
          .enterKeyType(EnterKeyType.Next)
      }
      .width('100%')
      .margin({ bottom: 20 })

      Row() {
        Text("链接")
          .fontSize(20)
          .margin({ top: 5 })
        TextInput({
          placeholder: '项目链接',
          text: $$this.url
        })
          .width("100%")
          .height(40)
          .layoutWeight(1)
          .borderRadius(15)
          .margin({ left: 15 })
          .fontSize(20)
          .placeholderFont({
            size: 20
          })
          .enterKeyType(EnterKeyType.Next)
      }
      .width('100%')
      .margin({ bottom: 20 })
      .alignItems(VerticalAlign.Top)

      Button({ type: ButtonType.Normal }) {
        Text("确认")
          .fontSize(20)
      }
      .width('100%')
      .height(50)
      .borderRadius(15)
      .backgroundColor('#E9E9E9')
      .onClick(async () => {
        if (this.name !== '' && this.url !== '') {
          if (this.title === '新建') {
            this.items.push({
              icon: this.icon,
              name: this.name,
              url: this.url
            })
          } else if (this.title === '编辑') {
            this.items[this.index] = {
              icon: this.icon,
              name: this.name,
              url: this.url
            }
          }
          this.createItem.close()
          promptAction.showToast({
            message: this.title + '成功！',
            duration: 500
          });
        } else if (this.name === '') {
          promptAction.showToast({
            message: '项目名称不能为空！',
            duration: 500
          });
        } else if (this.url === '') {
          promptAction.showToast({
            message: '项目链接不能为空！',
            duration: 500
          });
        }
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
  }
}