import Foundation

class PoliciesViewModel: ObservableObject {
    private weak var coordinator: BaseCoordinator?

    init(coordinator: BaseCoordinator?) {
        self.coordinator = coordinator
    }

    func dismiss() {
        coordinator?.dismiss()
    }

    let privacyPolicyHtml =
        "<p>Pobike AS (\"us\", \"we\", or \"our\") operates the Podbike Frikar mobile application (the \"Service\").</p>" +
        "<p>This page informs you of our policies regarding the collection, " +
        "use and disclosure of Personal Information when you use our Service.</p>" +
        "<p>We will not use or share your information with anyone except as described in this Privacy Policy.</p>" +
        "<p>We use your Personal Information for providing and improving the Service. " +
        "By using the Service, you agree to the collection and use of information in accordance with this policy. " +
        "Unless otherwise defined in this Privacy Policy, " +
        "terms used in this Privacy Policy have the same meanings as in our Terms and Conditions.</p>" +
        "<h3>A note about application permissions</h3>" +
        "<p>This application requires a specific privacy policy because it uses the \"Location\" permission. " +
        "It is important to note that the app DOES NOT TRACK YOUR LOCATION. " +
        "We require the \"Location\" permission to be able to access the Bluetooth functionality on your mobile device. " +
        "We also require permission to find nearby devices in order to connect to out Frikars. " +
        "The location-based functions are set by default and can be deactivated in the settings of your respective device. " +
        "However, this may result in the application not behaving as intended. " +
        "Finally, this application DOES NOT collect any personal information from our users.</p>" +
        "</span>"

    let privacyFutherInfo = "For further information on the policy, please click [here](https://www.podbike.com/privacy-and-cookie-policy/)"

    let termsAndConditionsHtml =
        "<p>These Terms and Conditions of Use (the \"Terms of Use\") apply to the Podbike Frikar mobile applications. " +
        "The application is the property of Podbike AS and its licensors. " +
        "BY USING THE APPLICATION, YOU AGREE TO THESE TERMS OF USE; IF YOU DO NOT AGREE, DO NOT AGREE, DO NOT USE THE APPLICATION.</p>" +
        "<p>Podbike reserves the right, at its sole discretion, to change, modify, add and remove portions of these Terms of Use, at any time. " +
        "It is your responsibility to check these Terms of Use periodically for changes. " +
        "Your continued use of the application following the posting of changes will mean that you accept and agree to the changes. " +
        "As long as you comply with these Terms of Use, Podbike grants you a personal, non-exclusive, limited privilege to use the application"

    let termsFutherInfo = "For further information on the terms and conditions, please click [here](https://www.podbike.com/podbike-terms-conditions/)"
}
