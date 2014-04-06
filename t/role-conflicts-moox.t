use strictures 1;
use Test::More;
use Test::Fatal;

{
  package MooX::ExtendHas;
  BEGIN { $INC{'MooX/ExtendHas.pm'} = __FILE__ }
  use Class::Method::Modifiers qw(install_modifier);
  sub import {
    my $target = caller;
    install_modifier $target, 'around', 'has', sub {
      my $orig = shift;
      $orig->(@_);
    };
  }
}

{
  package MyClass;
  use Moo;
}

{
  package MyRole1;
  use Moo::Role;
  use MooX::ExtendHas;

  has foo => (is => "ro");
}

{
  package MyRole2;
  use Moo::Role;
  use MooX::ExtendHas;

  has bar => (is => "ro");
}

is exception {
  Moo::Role->create_class_with_roles('MyClass', qw(MyRole1 MyRole2))
}, undef, "extending has in roles doesn't cause conflicts";

done_testing;
