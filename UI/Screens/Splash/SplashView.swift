import SwiftUI

struct SplashView: View {
    let viewModel: SplashViewModel

    var body: some View {
        ZStack {
            Color(.splashScreenBackground)
            Image(.splashScreen)
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.didAppear()
        }
    }
}

#Preview {
    SplashServiceLocator.instance.provideSplashView(coordinator: nil)
}
