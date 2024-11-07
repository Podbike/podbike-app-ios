import SwiftUI

struct TutorialPage3: View {
    var body: some View {
        VStack {
            Text("TutorialScreen").headline
                .multilineTextAlignment(.center)

            Spacer()

            Image(.Tutorial.symbols)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)

            Spacer()

            Image(.Tutorial.statistics)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)

            AppSpacers.h16

            Text("TutorialLogo").label

            Spacer()
        }
    }
}

#Preview {
    TutorialServiceLocator.instance.provideTutorialView(
        coordinator: RootCoordinatorViewModel(parentCoordinator: nil),
        startFromPage: 3
    )
}
