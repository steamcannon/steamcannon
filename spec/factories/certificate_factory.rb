Factory.define :certificate do |cert|
  cert.cert_type Certificate::CA_TYPE
  cert.certificate 'the cert'
  cert.keypair 'the keypair'
end

Factory.define :ca_certificate, :parent => :certificate do |cert|
end

Factory.define :client_certificate, :parent => :certificate do |cert|
  cert.cert_type Certificate::CLIENT_TYPE
end
