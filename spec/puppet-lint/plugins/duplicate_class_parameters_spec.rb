require 'spec_helper'

describe 'duplicate_class_parameters' do
  context 'when class has no parameters' do
    let(:code) do
      <<-TEST_CLASS
        class file_resource {
          file { '/tmp/my-file':
            mode => '0600',
          }
        }
      TEST_CLASS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'when class has a parameter' do
    let(:code) do
      <<-TEST_CLASS
        class file_resource(
          $unique = 'bar',
        ) {

          file { '/tmp/my-file':
            mode => '0600',
          }

          $baz = 'xxzzy'
        }
      TEST_CLASS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'when class has a duplicate right hand side' do
    let(:code) do
      <<-TEST_CLASS
        class duplicated_rhs(
          $nagios_innodb_enable = $sys11mysql,
          $nagios_myisam_enable = $sys11mysql,
        ) {
          file { '/tmp/my-file':
            mode => '0600',
          }
        }
      TEST_CLASS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'when class has types and a duplicate right hand side' do
    let(:code) do
      <<-TEST_CLASS
        class duplicated_rhs(
          Boolean $nagios_innodb_enable = $sys11mysql::params::production_environment,
          Boolean $nagios_myisam_enable = $sys11mysql::params::production_environment,
        ) {
          file { '/tmp/my-file':
            mode => '0600',
          }
        }
      TEST_CLASS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  # bug found where a string on the RHS has a variable in it
  context 'when class has a string containing a variable on the right hand side' do
    let(:code) do
      <<-TEST_CLASS
        class duplicated_string_rhs(
          $initial  = $sys11mysql,
          $stringed = "String containing ${initial}",
        ) {
          file { '/tmp/my-file':
            mode => '0600',
          }
        }
      TEST_CLASS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  # Examples that should fail specs

  context 'when class has duplicate parameters' do
    let(:msg) { 'found duplicate parameter \'duplicated\' in class \'file_resource\'' }
    let(:code) do
      <<-TEST_CLASS
        class file_resource(
          $duplicated = { 'a' => 1 },
          $duplicated = 'foo',
          $not_unique = 'bar',
          $not_unique = '2nd bar',
          $unique = 'baz'
        ) {

          file { '/tmp/my-file':
            mode => '0600',
          }

          $baz = 'xxzzy'
        }
      TEST_CLASS
    end

    it 'detects two problems' do
      expect(problems).to have(2).problems
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(msg).on_line(3).in_column(11)
    end

    it 'creates two warnings' do
      expect(problems).to contain_warning(msg).on_line(3).in_column(11)
      expect(problems).to contain_warning(msg.sub('duplicated', 'not_unique')).on_line(5).in_column(11)
    end
  end

  context 'when class has a type and duplicate parameters' do
    let(:msg) { 'found duplicate parameter \'not_unique\' in class \'duplicated_type\'' }
    let(:code) do
      <<-TEST_CLASS
        class duplicated_type(
          Boolean $not_unique = true,
          Boolean $not_unique = false,
        ) {

          file { '/tmp/my-file':
            mode => '0600',
          }

          $baz = 'xxzzy'
        }
      TEST_CLASS
    end

    it 'detects two problems' do
      expect(problems).to have(1).problems
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(msg).on_line(3).in_column(19)
    end
  end

  context 'when class has a structure using a variable and assigned in another variable' do
    let(:code) do
      <<-TEST_CLASS
        class complex_structure_assignation (
          Optional[String] $hostname = undef,
          Array[String] $aliases = ["www.${hostname}"],
        ) {
          if $hostname {
            # ...
          }
        }
      TEST_CLASS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end
end
