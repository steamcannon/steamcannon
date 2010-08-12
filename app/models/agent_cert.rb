class AgentCert
  def self.generate(name, type)
    keypair = OpenSSL::PKey::RSA.new(1024) { putc "." }
    cert = OpenSSL::X509::Certificate.new
    cert.version = 3
    cert.serial = 0
    name = OpenSSL::X509::Name.parse("/CN=#{name}")
    cert.subject = name
    cert.issuer = name
    cert.not_before = Time.now
    cert.not_after = Time.now + (365*24*60*60)
    cert.public_key = keypair.public_key

    ef = OpenSSL::X509::ExtensionFactory.new(nil, cert)
    ef.issuer_certificate = cert
    cert.extensions =
      [ef.create_extension("basicConstraints", "CA:FALSE"),
       ef.create_extension("keyUsage", "keyEncipherment"),
       ef.create_extension("subjectKeyIdentifier", "hash"),
       ef.create_extension("extendedKeyUsage", type)
      ]
    aki = ef.create_extension("authorityKeyIdentifier",
                              "keyid:always,issuer:always")
    cert.sign(keypair, OpenSSL::Digest::SHA1.new)
    [keypair.to_pem, cert.to_pem]
  end
end
