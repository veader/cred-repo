require 'openssl'

module Pi
  class Secrets
    class << self
      SALT_FOR_PADDING = 'some_random_text'

      def encrypt(env, source_filename)
        key = request_key(env)
        blob_filename = calculate_filename(env, source_filename, key)

        full_blob_filename = File.join(BLOB_DATA_DIR, blob_filename)

        if File.exists?(full_blob_filename)
          # TODO: detect exist and ask to overwrite it...
        end

        contents = File.read(source_filename)
        encrypted_contents = _encrypt(env, source_filename, key, contents)
        File.open(full_blob_filename, 'w+') { |f| f << encrypted_contents }

        puts "Encryption complete. Blob stored."
      end

      def decrypt(env, source_filename)
        key = request_key(env)
        blob_filename = calculate_filename(env, source_filename, key)

        full_blob_filename = File.join(BLOB_DATA_DIR, blob_filename)

        if !File.exists?(full_blob_filename)
          puts "Unable to find referenced file."
          return
        end

        contents = File.read(full_blob_filename)
        decrypted_contents = _decrypt(env, source_filename, key, contents)
        puts decrypted_contents # echo
      end

      # ---------------------------------------------------------------------
      private
        def request_key(env)
          print "Key for #{env}: "
          STDIN.gets.chomp
        end

        def calculate_filename(env, filename, key)
          base_filename = File.basename(filename)
          OpenSSL::HMAC.hexdigest('sha1', padded_env(env)+key, base_filename)
        end

        def _encrypt(env, filename, key, plaintext_data)
          base_filename = File.basename(filename)

          cipher = get_cipher
          cipher.encrypt
          cipher.key = padded_key(key)
          cipher.iv = padded_key(env + base_filename)
          cipher.update(plaintext_data) + cipher.final
        end

        def _decrypt(env, filename, key, encrypted_data)
          base_filename = File.basename(filename)

          cipher = get_cipher
          cipher.decrypt
          cipher.key = padded_key(key)
          cipher.iv = padded_key(env + base_filename)
          cipher.update(encrypted_data) + cipher.final
        end

        def get_cipher
          OpenSSL::Cipher::AES.new(128, :CBC)
        end

        def padded_key(key, size=128)
          key.ljust(size, SALT_FOR_PADDING)
        end

        def padded_env(env, size=20)
          env.ljust(size, '*')
        end

    end
  end
end