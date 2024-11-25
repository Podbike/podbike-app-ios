import SwiftUI

struct TutorialView: View {
    @ObservedObject var viewModel: TutorialViewModel

    init(viewModel: TutorialViewModel) {
        self.viewModel = viewModel
    }

    let pageCount = 4

    @ViewBuilder
    private func tutorialPage(_ page: Int) -> some View {
        switch page {
        case 1: TutorialPage1()
        case 2: TutorialPage2()
        case 3: TutorialPage3()
        default: TutorialPage4()
        }
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            VStack {
                TabView(selection: $viewModel.selectedPage) {
                    ForEach(1 ... pageCount, id: \.self) {
                        tutorialPage($0)
                            .padding(.horizontal, AppDimens.padding16)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.default, value: viewModel.selectedPage)

                let isLastPage = viewModel.selectedPage >= pageCount
                Button(
                    isLastPage ? "TutorialStart" : "TutorialNext",
                    action: {
                        if isLastPage { viewModel.closeTutorial() }
                        else { viewModel.selectedPage += 1 }
                    }
                )
                .buttonStyle(AppButton.primary)

                AppSpacers.h8

                let isFirstPage = viewModel.selectedPage <= 1
                Button(
                    isFirstPage ? "TutorialExit" : "TutorialPrevious",
                    action: {
                        if isFirstPage { viewModel.closeTutorial() }
                        else { viewModel.selectedPage -= 1 }
                    }
                )
                .buttonStyle(AppButton.secondary)
            }
            .padding(.top, AppDimens.padding48)
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    TutorialServiceLocator.instance.provideTutorialView(coordinator: nil)
}
