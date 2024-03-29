#!/usr/bin/perl
#
#  Copyright (c) 2011-2017 FastMail Pty Ltd. All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
#
#  3. The name "Fastmail Pty Ltd" must not be used to
#     endorse or promote products derived from this software without
#     prior written permission. For permission or any legal
#     details, please contact
#      FastMail Pty Ltd
#      PO Box 234
#      Collins St West 8007
#      Victoria
#      Australia
#
#  4. Redistributions of any form whatsoever must retain the following
#     acknowledgment:
#     "This product includes software developed by Fastmail Pty. Ltd."
#
#  FASTMAIL PTY LTD DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
#  INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY  AND FITNESS, IN NO
#  EVENT SHALL OPERA SOFTWARE AUSTRALIA BE LIABLE FOR ANY SPECIAL, INDIRECT
#  OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
#  USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
#  TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE
#  OF THIS SOFTWARE.
#

package Cassandane::Cyrus::Specialuse;
use strict;
use warnings;

use lib '.';
use base qw(Cassandane::Cyrus::TestCase);
use Cassandane::Util::Log;
use Cassandane::Instance;

sub new
{
    my $class = shift;
    return $class->SUPER::new({ adminstore => 1 }, @_);
}

sub set_up
{
    my ($self) = @_;
    $self->SUPER::set_up();
}

sub tear_down
{
    my ($self) = @_;
    $self->SUPER::tear_down();
}

# Test that you can rename a special use folder
sub test_rename_toplevel
    :NoAltNameSpace
{
    my ($self) = @_;

    my $imaptalk = $self->{store}->get_client();

    $imaptalk->create("INBOX.Junk", "(USE (\\Junk))");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    $imaptalk->rename("INBOX.Junk", "INBOX.Other");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());
}

sub test_rename_tosub
    :NoAltNameSpace
{
    my ($self) = @_;

    my $imaptalk = $self->{store}->get_client();

    $imaptalk->create("INBOX.Junk", "(USE (\\Junk))");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    $imaptalk->create("INBOX.Trash");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    # can't rename to a deep folder
    $imaptalk->rename("INBOX.Junk", "INBOX.Trash.Junk");
    $self->assert_equals('no', $imaptalk->get_last_completion_response());
}

sub test_create_multiple
    :NoAltNameSpace
{
    my ($self) = @_;

    my $imaptalk = $self->{store}->get_client();

    $imaptalk->create("INBOX.Rubbish", "(USE (\\Junk \\Trash \\Sent))");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());
}

sub test_create_dupe
    :NoAltNameSpace
{
    my ($self) = @_;

    my $imaptalk = $self->{store}->get_client();

    $imaptalk->create("INBOX.Rubbish", "(USE (\\Trash))");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    $imaptalk->create("INBOX.Trash", "(USE (\\Trash))");
    $self->assert_equals('no', $imaptalk->get_last_completion_response());
}

sub test_annot
{
    my ($self) = @_;

    my $imaptalk = $self->{store}->get_client();

    $imaptalk->create("INBOX.Trash");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    $imaptalk->setmetadata("INBOX.Trash", "/private/specialuse", "\\Trash");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());
}

sub test_annot_dupe
    :NoAltNameSpace
{
    my ($self) = @_;

    my $imaptalk = $self->{store}->get_client();

    $imaptalk->create("INBOX.Rubbish", "(USE (\\Trash))");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    $imaptalk->create("INBOX.Trash");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    $imaptalk->setmetadata("INBOX.Trash", "/private/specialuse", "\\Trash");
    $self->assert_equals('no', $imaptalk->get_last_completion_response());
}

sub test_delete_imm
    :ImmediateDelete :NoAltNameSpace
{
    my ($self) = @_;

    my $imaptalk = $self->{store}->get_client();

    $imaptalk->create("INBOX.Trash", "(USE (\\Trash))");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    $imaptalk->delete("INBOX.Trash");
    $self->assert_equals('no', $imaptalk->get_last_completion_response());
}

sub test_delete_delay
    :DelayedDelete :NoAltNameSpace
{
    my ($self) = @_;

    my $imaptalk = $self->{store}->get_client();

    $imaptalk->create("INBOX.Trash", "(USE (\\Trash))");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    $imaptalk->delete("INBOX.Trash");
    $self->assert_equals('no', $imaptalk->get_last_completion_response());
}

sub test_delete_removed_imm
    :ImmediateDelete :NoAltNameSpace
{
    my ($self) = @_;

    my $imaptalk = $self->{store}->get_client();

    $imaptalk->create("INBOX.Trash", "(USE (\\Trash))");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    $imaptalk->setmetadata("INBOX.Trash", "/private/specialuse", undef);
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    $imaptalk->delete("INBOX.Trash");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());
}

sub test_delete_removed_delay
    :DelayedDelete :NoAltNameSpace
{
    my ($self) = @_;

    my $imaptalk = $self->{store}->get_client();

    $imaptalk->create("INBOX.Trash", "(USE (\\Trash))");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    $imaptalk->setmetadata("INBOX.Trash", "/private/specialuse", undef);
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    $imaptalk->delete("INBOX.Trash");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());
}

sub test_important
    :min_version_3_1 :NoAltNameSpace
{
    my ($self) = @_;

    my $imaptalk = $self->{store}->get_client();

    $imaptalk->create("INBOX.Important", "(USE (\\Important))");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    $imaptalk->delete("INBOX.Important");
    $self->assert_equals('no', $imaptalk->get_last_completion_response());
}

sub test_nochildren
    :min_version_3_7 :NoStartInstances :NoAltNamespace
{
    my ($self) = @_;

    $self->{instance}->{config}->set('specialuse_nochildren' => '\\Trash');
    $self->_start_instances();

    my $imaptalk = $self->{store}->get_client();

    $imaptalk->create("INBOX.Trash", "(USE (\\Trash))");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    # should not be able to create a child
    $imaptalk->create("INBOX.Trash.child");
    $self->assert_equals('no', $imaptalk->get_last_completion_response());

    # should not be able to create a grandchild either
    $imaptalk->create("INBOX.Trash.child.grandchild");
    $self->assert_equals('no', $imaptalk->get_last_completion_response());

    # better not have accidentally created anything
    $imaptalk->select("INBOX.Trash.child");
    $self->assert_equals('no', $imaptalk->get_last_completion_response());

    $imaptalk->select("INBOX.Trash.child.grandchild");
    $self->assert_equals('no', $imaptalk->get_last_completion_response());

    # what if we remove the annotation
    $imaptalk->setmetadata("INBOX.Trash", "/private/specialuse", undef);
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    # should be able to create a child
    $imaptalk->create("INBOX.Trash.child");
    $self->assert_equals('ok', $imaptalk->get_last_completion_response());

    # should not be able to add the annotation back
    $imaptalk->setmetadata("INBOX.Trash", "/private/specialuse", '\\Trash');
    $self->assert_equals('no', $imaptalk->get_last_completion_response());
}

# compile
1;
