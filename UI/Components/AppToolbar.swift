import SwiftUI

private var canGoBack = true

extension View {
    func toolbar(
        title: LocalizedStringKey,
        showBackButton: Bool = true,
        onBack: @escaping @MainActor () -> Void
    ) -> some View {
        self
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    HStack {
                        if showBackButton {
                            Button(action: onBack) {
                                AppIcon.arrowLeft.size(48).foregroundStyle(AppColor.white)
                            }
                            .padding(AppDimens.padding16)
                        } else {
                            Spacer()
                        }

                        Text(title).pageTitle
                            .padding([.top, .bottom, .trailing], AppDimens.padding16)

                        Spacer()
                    }
                    .padding(.vertical, AppDimens.padding32)
                }
            }
            .onAppear {
                canGoBack = showBackButton
            }
    }
}

private class NavigationGestureDelegate: NSObject, UIGestureRecognizerDelegate {
    var navigationController: UINavigationController?

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationController else { return false }
        let isAtRoot = navigationController.viewControllers.count <= 1
        return canGoBack && !isAtRoot
    }
}

private let navigationGestureDelegate = NavigationGestureDelegate()

extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        navigationGestureDelegate.navigationController = self
        interactivePopGestureRecognizer?.delegate = navigationGestureDelegate
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
