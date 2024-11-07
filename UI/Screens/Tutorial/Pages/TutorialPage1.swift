import SwiftUI

struct TutorialPage1: View {
    var body: some View {
        VStack {
            Text("TutorialWelcome").headline

            Spacer()
            Spacer()

            Image(.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)

            Spacer()

            Text("TutorialIntroduction").label

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    TutorialServiceLocator.instance.provideTutorialView(
        coordinator: RootCoordinatorViewModel(parentCoordinator: nil),
        startFromPage: 1
    )
}
