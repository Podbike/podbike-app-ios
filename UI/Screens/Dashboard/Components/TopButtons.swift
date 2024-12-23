import SwiftUI

struct TopButtons: View {
    @ObservedObject var viewModel: DashboardViewModel
    let rowHeight: Double

    var body: some View {
        HStack {
            Button(action: viewModel.toggleHelp) {
                AppIcon.help.size(rowHeight).foregroundStyle(AppColor.white)
            }

            Spacer()

            Button(action: viewModel.goToStatisticsScreen) {
                Image(.logoSmall)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 42)
            }
            .modifier(Shake(animatableData: viewModel.isShowingHelpInfo ? 1 : 0))
            .animation(
                .spring(duration: 4, bounce: 1).repeatForever(),
                value: viewModel.isShowingHelpInfo
            )

            Spacer()

            Button(action: viewModel.goToSettingsScreen) {
                AppIcon.settings.size(rowHeight).foregroundStyle(AppColor.white)
            }
        }
    }

    struct Shake: GeometryEffect {
        var amount: CGFloat = 3
        var shakesPerUnit = 3
        var animatableData: CGFloat

        func effectValue(size: CGSize) -> ProjectionTransform {
            ProjectionTransform(
                CGAffineTransform(
                    translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                    y: 0
                )
            )
        }
    }
}
