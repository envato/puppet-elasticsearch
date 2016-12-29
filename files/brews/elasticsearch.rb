class Elasticsearch < Formula
  homepage "http://www.elastic.co"
  url "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.1.1.tar.gz"
  sha256 "cd45bafb1f74a7df9bad12c77b7bf3080069266bcbe0b256b0959ef2536e31e8"
  version '5.1.1-boxen1'

  head do
    url "https://github.com/elastic/elasticsearch.git"
    depends_on "maven"
  end

  def cluster_name
    "elasticsearch_#{ENV["USER"]}"
  end

  def install
    if build.head?
      # Build the package from source
      system "mvn", "clean", "package", "-DskipTests"
      # Extract the package to the current directory
      system "tar", "--strip", "1", "-xzf", "target/releases/elasticsearch-*.tar.gz"
    end

    # Remove Windows files
    rm_f Dir["bin/*.bat"]
    rm_f Dir["bin/*.exe"]

    # Move libraries to `libexec` directory
    libexec.install Dir["lib/*.jar"]

    # No longer a thing in ES 5?
    # (libexec/"sigar").install Dir["lib/sigar/*.{jar,dylib}"]

    # Install everything else into package directory
    prefix.install Dir["*"]

    # Remove unnecessary files
    rm_f Dir["#{lib}/sigar/*"]
    if build.head?
      rm_rf "#{prefix}/pom.xml"
      rm_rf "#{prefix}/src/"
      rm_rf "#{prefix}/target/"
    end

    inreplace "#{bin}/elasticsearch.in.sh" do |s|
      # Configure ES_HOME
      s.sub!(%r{#\!/bin/bash\n}, "#!/bin/bash\n\nES_HOME=#{prefix}")
      # Configure ES_CLASSPATH paths to use libexec instead of lib
      s.gsub!(%r{ES_HOME/lib/}, "ES_HOME/libexec/")
    end

    inreplace "#{bin}/elasticsearch-plugin" do |s|
      # Add the proper ES_CLASSPATH configuration
      s.sub!(/SCRIPT="\$0"/, %(SCRIPT="$0"\nES_CLASSPATH=#{libexec}))
      # Replace paths to use libexec instead of lib
      s.gsub!(%r{\$ES_HOME/lib/}, "$ES_CLASSPATH/")
    end
  end
end
