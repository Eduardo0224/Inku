import SwiftUI

extension View {

    @ViewBuilder
    func conditionalLabelIconSpacing(_ spacing: CGFloat) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            self.labelIconToTitleSpacing(spacing)
        } else {
            self
        }
        #elseif os(macOS)
        if #available(macOS 26.0, *) {
            self.labelIconToTitleSpacing(spacing)
        } else {
            self
        }
        #elseif os(visionOS)
        if #available(visionOS 26.0, *) {
            self.labelIconToTitleSpacing(spacing)
        } else {
            self
        }
        #else
        self
        #endif
    }
}
