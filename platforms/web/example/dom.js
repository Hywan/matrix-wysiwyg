export function computeSelectionOffset(node, offset) {
    if (node && node.nodeType === Node.TEXT_NODE) {
        return offset !== undefined ? offset : node.textContent.length
    } else if (node.hasChildNodes()) {
        return Array.from(node.childNodes).map(childNode => computeSelectionOffset(childNode)).reduce((prev, curr) => prev + curr, 0)
    } else {
        return 0
    }
}
