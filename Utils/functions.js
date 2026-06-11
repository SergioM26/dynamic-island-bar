// functions.js
function getHeight(modelData, mode) {
    if (!modelData)
        return 0;
    if (mode === "hover") {
        return modelData.height * 0.05;
    }
    return modelData.height * 0.04;
}
function getWidth(modelData, mode) {
    if (!modelData)
        return 0;
    if (mode === "hover") {
        return modelData.width * 0.15;
    }
    return modelData.width * 0.09;
}
