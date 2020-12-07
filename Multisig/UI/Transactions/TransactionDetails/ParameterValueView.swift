//
//  ParameterValueView.swift
//  Multisig
//
//  Created by Dmitry Bespalov on 19.08.20.
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import SwiftUI

struct ParameterValueView: View {
    var type: String
    var value: DataDecodedParameterValue?
    var nestingLevel: Int = 0

    var body: some View {
        valueView.padding(.leading, nestingLevel == 0 ? 0 : 8)
    }

    @ViewBuilder
    var valueView: some View {
        if let address = value?.addressValue {
            AddressCell(address: address.checksummed)
        } else if let string = stringValue {
            if type.starts(with: "bytes"), let data = value?.dataValue {
                ExpandableButton(title: "\(data.count) bytes", value: string)
            } else {
                Text(string).body(.gnoDarkGrey)
            }
        } else {
            ExpandableView(title: Text("array").body(.gnoDarkGrey),
                           value: arrayContent)
        }
    }

    var arrayContent: some View {
        ForEach((0..<value!.arrayValue!.count)) { index in
            ParameterValueView(type: type,
                               value: self.value!.arrayValue![index],
                               nestingLevel: self.nestingLevel + 1)
        }
    }

    var stringValue: String? {
        guard let value = value else { return "-" }
        if value.arrayValue == nil && value.stringValue == nil {
            return "Unsupported type of value"
        } else if let array = value.arrayValue, array.isEmpty {
            return "empty"
        }

        return value.stringValue
    }
}

struct ParameterValueView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ParameterValueView(type: "String", value: ["Hello","Hello", "Hello", ["Hello", "Hello"]])
        }
    }
}

struct ParameterValueViewV2: View {
    var type: String
    var value: SCG.DataDecoded.Parameter.Value
    var nestingLevel: Int = 0

    var body: some View {
        valueView.padding(.leading, nestingLevel == 0 ? 0 : 8)
    }

    @ViewBuilder
    var valueView: some View {
        switch value {
        case .address(let address):
            AddressCell(address: address.address.checksummed)
        case .data(let data):
            ExpandableButton(title: "\(data.data.count) bytes", value: data.description)
        case .uint256(let uint):
            Text(uint.description).body(.gnoDarkGrey)
        case .string(let string):
            Text(string).body(.gnoDarkGrey)
        case .unknown:
            Text("Unknown value").body(.gnoDarkGrey)
        case .array(let array):
            if array.isEmpty {
                Text("empty").body(.gnoDarkGrey)
            } else {
                ExpandableView(title: Text("array").body(.gnoDarkGrey),
                               value: arrayContent(array))
            }
        }
    }

    func arrayContent(_ array: [SCG.DataDecoded.Parameter.Value]) -> some View {
        ForEach(0..<array.count) { index in
            ParameterValueViewV2(
                type: type,
                value: array[index],
                nestingLevel: nestingLevel + 1)
        }
    }

}
