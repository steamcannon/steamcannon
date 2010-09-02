#
# Copyright 2010 Red Hat, Inc.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 3 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.


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
