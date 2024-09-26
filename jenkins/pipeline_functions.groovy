#!/usr/bin/env groovy

def determineVersionChange() {
    def commitMessage = sh(script: 'git log -1 --pretty=%B', returnStdout: true).trim().toLowerCase()
    if (commitMessage.contains('[major]')) {
        return 'MAJOR'
    } else if (commitMessage.contains('[minor]')) {
        return 'MINOR'
    } else if (commitMessage.contains('[patch]')) {
        return 'PATCH'
    }
    return 'NONE'
}

def incrementVersion(versionFile, versionChange) {
    def currentVersion = readFile(versionFile).trim()
    def (major, minor, patch) = currentVersion.tokenize('.').collect { it.toInteger() }
   
    switch(versionChange) {
        case 'MAJOR':
            major++
            break
        case 'MINOR':
            minor++
            break
        case 'PATCH':
        case 'NONE':
            patch++
            break
    }
   
    def newVersion = "${major}.${minor}.${patch}"
    writeFile file: versionFile, text: newVersion
    return newVersion
}

def updateComponentVersion(componentName, versionFile, changed, versionChange) {
    if (changed == 'true') {
        def newVersion = incrementVersion(versionFile, versionChange)
        echo "New ${componentName} version: ${newVersion}"
        return newVersion
    } else {
        def currentVersion = readFile(versionFile).trim()
        echo "${componentName} not changed. Keeping version: ${currentVersion}"
        return currentVersion
    }
}

return this