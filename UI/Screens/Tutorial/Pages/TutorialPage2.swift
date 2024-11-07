import SwiftUI

struct TutorialPage2: View {
    var body: some View {
        VStack {

            Text("TutorialSymbols").headline
                .multilineTextAlignment(.center)

            Spacer()
            Spacer()
            Spacer()

            Text("TutorialAssistance").label

            AppSpacers.h12

            Image(.Tutorial.electricAssistance)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, AppDimens.padding16)

            Spacer()
            Spacer()

            Text("TutorialCadence").label

            AppSpacers.h12

            Image(.Tutorial.cadence)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, AppDimens.padding16)

            Spacer()
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    TutorialServiceLocator.instance.provideTutorialView(
        coordinator: RootCoordinatorViewModel(parentCoordinator: nil),
        startFromPage: 2
    )
}
