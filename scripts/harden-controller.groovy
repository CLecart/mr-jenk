// scripts/harden-controller.groovy
// Quick, idempotent hardening for Jenkins controller.
// Usage: Manage Jenkins -> Script Console -> paste and run.
// This script sets number of executors to 0, enables CSRF (crumb issuer),
// disables the legacy slave agent TCP port (sets to -1) and saves configuration.

import jenkins.model.*
import hudson.security.csrf.DefaultCrumbIssuer

def j = Jenkins.get()
println "Jenkins version: ${j.getVersion()}"

println "Num executors (before): ${j.getNumExecutors()}"
if (j.getNumExecutors() != 0) {
    j.setNumExecutors(0)
    println "Set num executors to 0"
} else {
    println "Num executors already 0"
}

try {
    def crumb = j.getCrumbIssuer()
    if (crumb == null) {
        j.setCrumbIssuer(new DefaultCrumbIssuer(true))
        println "Enabled CSRF crumb issuer"
    } else {
        println "Crumb issuer already configured: ${crumb.getClass().getName()}"
    }
} catch (e) {
    println "CSRF configuration change failed: ${e}"
}

try {
    def port = j.getSlaveAgentPort()
    println "Slave agent TCP port (before): ${port}"
    if (port != -1) {
        j.setSlaveAgentPort(-1)
        println "Disabled slave agent TCP port (set to -1)"
    } else {
        println "Slave agent TCP port already disabled"
    }
} catch (e) {
    println "Could not change slave agent port: ${e}"
}

j.save()
println "Saved Jenkins configuration. Review settings in Manage Jenkins -> Configure Global Security."

println "Recommendation: configure Matrix-based security or an external identity provider (LDAP/OAuth/SSO) and review installed plugins."
