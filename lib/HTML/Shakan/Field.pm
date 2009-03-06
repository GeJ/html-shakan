package HTML::Shakan::Field;
use Any::Moose;
use HTML::Entities 'encode_entities';

has id => (
    is => 'rw',
    isa => 'Str',
    trigger => sub {
        my ($self, $id) = @_;
        $self->{attr}->{id} = $id;
    },
);

has name => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    trigger  => sub {
        my ( $self, $name ) = @_;
        $self->{attr}->{name} = $name;
    },
);

has value => (
    is       => 'rw',
    isa      => 'Str',
    required => 0,
    trigger  => sub {
        my ( $self, $value ) = @_;
        $self->{attr}->{value} = $value;
    },
);

has filters => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { +[] }
);

has widget => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has attr => (
    is => 'ro',
    isa => 'HashRef',
    lazy => 1,
    default => sub {
        +{}
    },
);

has label => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub { shift->name }
);

has required => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

has constraints => (
    is  => 'ro',
    isa => 'ArrayRef',
    default => sub { +[] },
);

sub add_constraint {
    my ($self, @constraint) = @_;
    push @{$self->{constraints}}, @constraint;
    $self; # method chain
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

