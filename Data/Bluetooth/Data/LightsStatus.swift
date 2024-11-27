struct LightsStatus {
    let lowBeam: Bool
    let highBeam: Bool
    let rearLight: Bool
    let brakeLight: Bool
    let indicatorLeft: Bool
    let indicatorRight: Bool
    let reverseLight: Bool
    let runningLight: Bool

    init(
        lowBeam: Bool = false,
        highBeam: Bool = false,
        rearLight: Bool = false,
        brakeLight: Bool = false,
        indicatorLeft: Bool = false,
        indicatorRight: Bool = false,
        reverseLight: Bool = false,
        runningLight: Bool = false
    ) {
        self.lowBeam = lowBeam
        self.highBeam = highBeam
        self.rearLight = rearLight
        self.brakeLight = brakeLight
        self.indicatorLeft = indicatorLeft
        self.indicatorRight = indicatorRight
        self.reverseLight = reverseLight
        self.runningLight = runningLight
    }
}
