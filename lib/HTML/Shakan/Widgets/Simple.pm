package HTML::Shakan::Widgets::Simple;
use Any::Moose;
with 'HTML::Shakan::Role::Widgets';
use HTML::Entities 'encode_entities';
use List::MoreUtils qw/zip/;

sub render {
    my ($self, $field) = @_;

    my $type = $field->widget;
    my $code = $self->can("widget_${type}") or die "unknown widget type: $type";
    $code->(
        $self, $field
    );
}

sub _attr {
    my $attr = shift;

    my @ret;

    for my $key (sort keys %$attr) {
        push @ret, sprintf(q{%s="%s"}, encode_entities($key), encode_entities($attr->{$key}));
    }
    join ' ', @ret;
}


sub widget_input {
    my ($self, $field) = @_;

    if (my $value = $self->form->fillin_param($field->{name})) {
        $field->value($value);
    }

    return '<input ' . _attr($field->attr) . " />";
}

sub widget_select {
    my ($self, $field) = @_;

    my $choices = $field->{choices};

    my $value = $self->form->fillin_param($field->{name});

    my @t;
    push @t, sprintf(q{<select %s>}, _attr($field->attr));
    while (my ($a, $b) = splice @$choices, 0, 2) {
        push @t, sprintf(
            q{<option value="%s"%s>%s</option>},
            $a,
            ($value && $value eq $a ? ' selected="selected"' : ''),
            $b);
    }
    push @t, q{</select>};
    return join "\n", @t;
}

sub widget_radio {
    my ($self, $field) = @_;

    my $choices = delete $field->{choices};

    my $value = $self->form->fillin_param($field->{name});

    my @t;
    push @t, "<ul>";
    while (my ($a, $b) = splice @$choices, 0, 2) {
        push @t, sprintf(
            q{<li><label><input type="radio" value="%s"%s />%s</label></li>},
            $a,
            ($value && $value eq $a ? ' checked="checked"' : ''),
            $b
        );
    }
    push @t, "</ul>";
    join "\n", @t;
}

sub widget_date {
    my ($self, $field) = @_;
    my $name = $field->{name} or die "missing name";
    my $years = $field->{years} or die "missing years";

    my $set = sub {
        my ($choices, $suffix) = @_;
        $self->widget_select(
            HTML::Shakan::Field::Choice->new(
                name => "${name}_${suffix}",
                choices => [zip(@$choices, @$choices)],
            )
        );
    };

    my @t;

    push @t, '<span>';

    push @t, $set->($years, 'year');
    push @t, $set->([1..12], 'month');
    push @t, $set->([1..31], 'day');

    push @t, '</span>';

    join "\n", @t;
}

sub field_filter {
    my ($self, $form, $field, $params) = @_;

    # TODO: inflate here???
    if ($field->widget eq 'date') {
        my @c;
        for my $k (qw/year month day/) {
            my $key = $field->name . '_' . $k;
            my $v = $form->request->param($key);
            if (defined $v) {
                $params->{$key} = $v;
                push @c, $v;
            }
        }

        if (@c == 3) {
            $params->{$field->name} = join '-', @c; # http-date style
        }
    }
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;
