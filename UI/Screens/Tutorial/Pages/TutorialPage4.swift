import SwiftUI

struct TutorialPage4: View {
    var body: some View {
        VStack {
            Text("TutorialButtons").headline
                .multilineTextAlignment(.center)

            Spacer()
            Spacer()

            Text("TutorialHandlebars").label

            Spacer()

            Image(.Tutorial.buttons)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 128)

            Spacer()

            Text("TutorialFurther").label

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    TutorialServiceLocator.instance.provideTutorialView(
        coordinator: RootCoordinatorViewModel(parentCoordinator: nil),
        startFromPage: 4
    )
}
