import SwiftUI

struct TutorialView: View {
    @ObservedObject var viewModel: TutorialViewModel

    init(viewModel: TutorialViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColor.background

            VStack() {
                Text("Tutorial").title
            }
            .padding(Paddings.defaultBorders)
        }
        .ignoresSafeArea()
        .onAppear { viewModel.didAppear() }
    }
}

#Preview {
    TutorialServiceLocator.instance.provideTutorialView(coordinator: RootCoordinatorViewModel(parentCoordinator: nil))
}
