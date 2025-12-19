// Idempotent Groovy script to provision Jenkins credentials.
// Usage: run from Jenkins Script Console as an administrator.
// IMPORTANT: Replace placeholder values before executing. Do NOT paste real secrets into shared repos.

import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.plugins.credentials.CredentialsScope
import com.cloudbees.plugins.credentials.impl.BasicSSHUserPrivateKey
import com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey.DirectEntryPrivateKeySource
import hudson.util.Secret

def jenkins = Jenkins.get()
def store = jenkins.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

// Helper: find credential by id in global domain
def findCredential(Class clazz, String id) {
  return CredentialsProvider.lookupCredentials(clazz, jenkins, null, null).find { it.id == id }
}

// Create or skip secret text credential
def ensureSecretText(String id, String secretPlaceholder, String description) {
  if (findCredential(org.jenkinsci.plugins.plaincredentials.StringCredentials.class, id)) {
    println "[SKIP] SecretText credential '${id}' already exists"
    return
  }
  println "[CREATE] SecretText credential '${id}' (placeholder). Replace value via UI if needed."
  def secret = Secret.fromString(secretPlaceholder)
  def cred = new org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl(
      CredentialsScope.GLOBAL, id, description, secret)
  store.addCredentials(Domain.global(), cred)
}

// Create or skip username/password credential
def ensureUsernamePassword(String id, String usernamePlaceholder, String passwordPlaceholder, String description) {
  if (findCredential(com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl.class, id)) {
    println "[SKIP] UsernamePassword credential '${id}' already exists"
    return
  }
  println "[CREATE] UsernamePassword credential '${id}' (placeholders)."
  def cred = new com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL, id, description, usernamePlaceholder, passwordPlaceholder)
  store.addCredentials(Domain.global(), cred)
}

// Create or skip SSH private key credential (direct entry)
def ensureSSHKey(String id, String usernamePlaceholder, String privateKeyPlaceholder, String description) {
  if (findCredential(BasicSSHUserPrivateKey.class, id)) {
    println "[SKIP] SSH private key credential '${id}' already exists"
    return
  }
  println "[CREATE] SSH private key credential '${id}' (placeholder)."
  def keySource = new DirectEntryPrivateKeySource(privateKeyPlaceholder)
  def cred = new BasicSSHUserPrivateKey(CredentialsScope.GLOBAL, id, usernamePlaceholder, keySource, null, description)
  store.addCredentials(Domain.global(), cred)
}

// --- Customize identifiers and placeholders below BEFORE running ---
// NOTE: Do NOT keep real secrets in repository files. Replace placeholders directly in the Script Console.

def credentialsToEnsure = [
  [type: 'secretText', id: 'ci-api-token-chris', value: 'REPLACE_WITH_SECRET_TEXT', desc: 'Token API pour CI (remplacer en console)'],
  [type: 'userpass', id: 'docker-registry-creds', user: 'REPLACE_USER', pass: 'REPLACE_PASSWORD', desc: 'Identifiants registry (remplacer en console)'],
