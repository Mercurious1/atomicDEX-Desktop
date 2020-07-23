import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

// Open Enable Coin Modal
DefaultModal {
    id: root

    width: 650
    property var details

    onDetailsChanged: {
        if(!details) root.close()
    }

    // Inside modal
    ColumnLayout {
        width: parent.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter

        ModalHeader {
            title: API.get().empty_string + (!details ? "" : details.is_swap ? qsTr("Swap Details") : qsTr("Order Details"))
        }

        // Complete image
        DefaultImage {
            visible: !details ? false : details.is_swap && details.order_status === "successful"
            Layout.alignment: Qt.AlignHCenter
            source: General.image_path + "exchange-trade-complete.svg"
        }

        // Loading symbol
            DefaultBusyIndicator {
            visible: !details ? false :
                     details.is_swap &&
                     details.order_status !== "successful" &&
                     details.order_status !== "failed"
            Layout.alignment: Qt.AlignHCenter
        }

        // Status Text
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            font.pixelSize: Style.textSize3
            visible: !details ? false : !details.is_maker
            color: !details ? "white" : visible ? getStatusColor(details.order_status) : ''
            text_value: API.get().empty_string + (!details ? "" : visible ? getStatusTextWithPrefix(details.order_status) : '')
        }

        OrderContent {
            Layout.topMargin: 25
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: Layout.leftMargin
            height: 120
            Layout.alignment: Qt.AlignHCenter
            details: root.details
            in_modal: true
        }

        HorizontalLine {
            Layout.fillWidth: true
            Layout.bottomMargin: 20
            color: Style.colorWhite8
        }

        // Maker/Taker
        DefaultText {
            text_value: API.get().empty_string + (!details ? "" : details.is_maker ? qsTr("Maker Order"): qsTr("Taker Order"))
            color: Style.colorThemeDarkLight
            Layout.alignment: Qt.AlignRight
        }

        // Refund state
        // TODO: Add events
//        TextFieldWithTitle {
//            Layout.topMargin: -20

//            title: API.get().empty_string + (qsTr("Refund State"))
//            field.text: {
//                if(!details) return ""

//                let str = API.get().empty_string
//                const e = getLastEvent(details)

//                if(e.state === "TakerPaymentWaitRefundStarted" ||
//                   e.state === "MakerPaymentWaitRefundStarted") {
//                    str += qsTr("Your swap failed but the auto-refund process for your payment started already. Please wait and keep application opened until you receive your payment back")
//                }

//                return str
//            }
//            field.readOnly: true

//            visible: field.text !== ''
//        }

        // Date
        TextWithTitle {
            title: API.get().empty_string + (qsTr("Date"))
            text: API.get().empty_string + (!details ? "" : details.date)
            visible: text !== ''
        }

        // ID
        TextWithTitle {
            title: API.get().empty_string + (qsTr("ID"))
            text: API.get().empty_string + (!details ? "" : details.order_id)
            visible: text !== ''
            privacy: true
        }

        // Payment ID
        TextWithTitle {
            title: API.get().empty_string + (!details ? "" : details.is_maker ? qsTr("Maker Payment Sent ID") : qsTr("Maker Payment Spent ID"))
            text: API.get().empty_string + (!details ? "" : details.maker_payment_id)
            visible: text !== ''
            privacy: true
        }

        // Payment ID
        TextWithTitle {
            title: API.get().empty_string + (!details ? "" : details.is_maker ? qsTr("Taker Payment Spent ID") : qsTr("Taker Payment Sent ID"))
            text: API.get().empty_string + (!details ? "" : details.taker_payment_id)
            visible: text !== ''
            privacy: true
        }

        // Error ID
        TextWithTitle {
            title: API.get().empty_string + (qsTr("Error ID"))
            text: API.get().empty_string + (!details ? "" : details.order_error_state)
            visible: text !== ''
        }

        // Error Details
        TextFieldWithTitle {
            title: API.get().empty_string + (qsTr("Error Log"))
            field.text: API.get().empty_string + (!details ? "" : details.order_error_message)
            field.readOnly: true
            copyable: true

            visible: field.text !== ''
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: API.get().empty_string + (qsTr("Close"))
                Layout.fillWidth: true
                onClicked: root.close()
            }

            // Cancel button
            DangerButton {
                visible: !details ? false : details.cancellable !== undefined && details.cancellable
                Layout.fillWidth: true
                text: API.get().empty_string + (qsTr("Cancel Order"))
                onClicked: { if(details) onCancelOrder(details.order_id) }
            }

            PrimaryButton {
                text: API.get().empty_string + (qsTr("View at Explorer"))
                Layout.fillWidth: true
                visible: !details ? false : details.maker_payment_id !== '' || details.taker_payment_id !== ''
                onClicked: {
                    if(!details) return

                    const maker_id = details.maker_payment_id
                    const taker_id = details.taker_payment_id
                    if(maker_id !== '') General.viewTxAtExplorer(details.base_coin, maker_id, true)
                    if(taker_id !== '') General.viewTxAtExplorer(details.rel_coin, taker_id, true)
                }
            }
        }
    }
}
