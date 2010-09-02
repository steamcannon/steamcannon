class Certificate < ActiveRecord::Base
  belongs_to :certifiable, :polymorphic => true

  validates_presence_of :cert_type, :certificate, :keypair

  CA_TYPE = 'ca'
  CLIENT_TYPE = 'client'
  INSTANCE_TYPE = 'instance'


  # TODO: encrypt/decrypt on read/write attribute?
  # we should probably
  # export the keypair with a password loaded at runtime, like so
  # (ganked from quickcert):
  #          cb = proc do @ca_config[:password] end
  #     keypair_export = keypair.export OpenSSL::Cipher::DES.new(:EDE3, :CBC),
  #                                     &cb
  
  def to_rsa_keypair
    @to_rsa_keypair ||= OpenSSL::PKey::RSA.new(keypair) #TODO: password
  end

  def to_x509_certificate
    @to_x509_certificate ||= OpenSSL::X509::Certificate.new(certificate)
  end
  
  class << self
    def ca_certificate
      @ca_certificate ||= Certificate.find_by_cert_type(Certificate::CA_TYPE) || generate_ca_certificate
    end

    def client_certificate
      @client_certificate ||= Certificate.find_by_cert_type(Certificate::CLIENT_TYPE) || generate_client_certificate
    end

    def generate_ssl_certificate(certable)
    end

    protected
    
    def generate_ca_certificate
      options = {
        :serial => 0,
        :self_signed => true,
        :subject => "O=SteamCannon Instance, CN=CA",
        :extensions => [
                        [ "basicConstraints", "CA:TRUE", true ],
                        [ "keyUsage", "cRLSign,keyCertSign", true ]
                       ]
      }
      
      cert, keypair = generate_certificate(options)

      Certificate.create(:type => Certificate::CA_TYPE,
                         :certificate => cert.to_pem,
                         :keypair => keypair.to_pem)
    end

    def generate_client_certificate
      options = {
        :serial => 1,
        :subject => "O=SteamCannon Instance, CN=Client",
        :extensions => [
                        [ "basicConstraints", "CA:FALSE", true ],
                        [ "keyUsage", "nonRepudiation, digitalSignature, keyEncipherment", true ],
                        ["extendedKeyUsage", "clientAuth"]
                       ]
      }
      
      cert, keypair = generate_certificate(options)

      Certificate.create(:type => Certificate::CLIENT_TYPE,
                         :certificate => cert.to_pem,
                         :keypair => keypair.to_pem)
      end

    def generate_certificate(options)
      keypair = OpenSSL::PKey::RSA.new(1024)
      cert = OpenSSL::X509::Certificate.new
      cert.version = 2 #x509v3 is 2 here. v1 is 0
      cert.serial = options[:serial]
      cert.subject = OpenSSL::X509::Name.parse(options[:subject])
      cert.issuer = options[:self_signed] ? cert.subject : ca_certificate.to_x509_certificate.subject
      cert.not_before = Time.now
      cert.not_after = Time.now + (10*365*24*60*60) #10 years
      cert.public_key = keypair.public_key

      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = cert
      ef.issuer_certificate = options[:self_signed] ? cert.subject : ca_certificate.to_x509_certificate
      options[:extensions] ||= []
      options[:extensions] << ["subjectKeyIdentifier", "hash"]
      cert.extensions = options[:extensions].collect do |extension|
        ef.create_extension(*extension)
      end
      
      cert.sign(options[:self_signed] ? keypair : ca_certificate.to_rsa_keypair, OpenSSL::Digest::SHA1.new)

      [cert, keypair]
    end
    
  end
end
