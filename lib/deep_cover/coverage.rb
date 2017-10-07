require 'parser'
require 'parser/current'
require 'pry'
require 'pathname'
require_relative 'covered_code'
require 'securerandom'

module DeepCover
  # A collection of CoveredCode
  class Coverage
    include Enumerable

    def initialize(**options)
      @covered_code = {}
      @options = options
    end

    def line_coverage(filename)
      covered_code(filename).line_coverage
    end

    def covered_code(path)
      raise 'path must be an absolute path' unless Pathname.new(path).absolute?
      @covered_code[path] ||= CoveredCode.new(path: path, **@options)
    end

    def each
      return to_enum unless block_given?
      @covered_code.each{|_path, covered_code| yield covered_code}
      self
    end

    def report
      missing = map do |covered_code|
        if covered_code.has_executed?
          missed = covered_code.line_coverage.each_with_index.map do |line_cov, line_index|
            line_index + 1 if line_cov == 0
          end.compact
        else
          missed = ['all']
        end
        [covered_code.buffer.name, missed] unless missed.empty?
      end.compact.to_h
      missing.map do |path, lines|
        "#{File.basename(path)}: #{lines.join(', ')}"
      end.join("\n")
    end

    def self.load(dest_path, dirname = 'deep_cover')
      Persistence.new(dest_path, dirname).load
    end

    def self.saved?(dest_path, dirname = 'deep_cover')
      Persistence.new(dest_path, dirname).saved?
    end

    def save(dest_path, dirname = 'deep_cover')
      Persistence.new(dest_path, dirname).save(self)
      self
    end

    def save_trackers(dest_path, dirname = 'deep_cover')
      Persistence.new(dest_path, dirname).save_trackers(tracker_global)
      self
    end

    def tracker_global
      @options[:tracker_global]
    end

    class Persistence
      BASENAME = 'coverage.dc'
      TRACKER_TEMPLATE = 'trackers%{unique}.dct'

      attr_reader :dir_path
      def initialize(dest_path, dirname)
        @dir_path = Pathname(dest_path).join(dirname).expand_path
      end

      def load
        saved?
        load_trackers
        load_coverage
      end

      def save(coverage)
        create_if_needed
        delete_trackers
        save_coverage(coverage)
      end

      def save_trackers(global)
        saved?
        basename = TRACKER_TEMPLATE % {unique: SecureRandom.urlsafe_base64}
        dir_path.join(basename).binwrite(Marshal.dump({
          version: DeepCover::VERSION,
          global: global,
          trackers: eval(global),
        }))
      end

      def saved?
        raise "Can't find folder '#{dir_path}'" unless dir_path.exist?
        self
      end

      private

      def create_if_needed
        dir_path.mkpath
      end

      def save_coverage(coverage)
        # TODO: don't persist covered_code's @cover
        dir_path.join(BASENAME).binwrite(Marshal.dump({
          version: DeepCover::VERSION,
          coverage: coverage,
        }))
      end

      def load_coverage
        # TODO: don't load covered_code's @cover
        Marshal.load(dir_path.join(BASENAME).binread).tap do |version: raise, coverage: raise|
          raise "dump version mismatch: #{deep_cover}, currently #{DeepCover::VERSION}" unless version == DeepCover::VERSION
          return coverage
        end
      end

      def load_trackers
        tracker_files.each do |full_path|
          Marshal.load(full_path.binread).tap do |version: raise, global: raise, trackers: raise|
            raise "dump version mismatch: #{deep_cover}, currently #{DeepCover::VERSION}" unless version == DeepCover::VERSION
            merge_trackers(eval("#{global} ||= {}"), trackers)
          end
        end
      end

      def merge_trackers(hash, to_merge)
        hash.merge!(to_merge) do |_key, current, to_add|
          unless current.size == 0 || current.size == to_add.size
            warn "Merging trackers of different sizes: #{current.size} vs #{to_add.size}"
          end
          to_add.zip(current).map{|a, b| a+b}
        end
      end

      def tracker_files
        basename = TRACKER_TEMPLATE % { unique: '*' }
        Pathname.glob(dir_path.join(basename))
      end

      def delete_trackers
        tracker_files.each(&:delete)
      end
    end
  end
end
