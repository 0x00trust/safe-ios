//
//  WhenSafeSelected.swift
//  Multisig
//
//  Created by Dmitry Bespalov on 07.10.20.
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import SwiftUI

struct WhenSafeSelected<Content: View>: View {
    var padding: (edge: Edge.Set, length: CGFloat) = (.all, 0)
    var noSafeEvent: TrackingEvent
    var content: () -> Content

    @FetchRequest(fetchRequest: Safe.fetchRequest().selected())
    private var selected: FetchedResults<Safe>

    private var isSelected: Bool {
        selected.first != nil
    }

    var body: some View {
        if isSelected {
            content()
        } else {
            AddSafeIntroView(padding: padding).onAppear {
                trackEvent(noSafeEvent)
            }
        }
    }
}
