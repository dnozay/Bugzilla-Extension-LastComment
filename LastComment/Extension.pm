# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.
#
# Contributor(s):
#   Damien Nozay <damien.nozay@gmail.com>

package Bugzilla::Extension::LastComment;
use strict;
use base qw(Bugzilla::Extension);
our $VERSION = '0.01';

sub buglist_columns {
    my ($self, $args) = @_;
    my $columns = $args->{'columns'};
    $columns->{'last_comment'} = {
        'name' => 'last_comment_tbl.lastcomment',
        'title' => 'Last Comment'
    };
    $columns->{'last_comment_60'} = {
        'name' => 'last_comment_tbl.lastcomment60',
        'title' => 'Last Comment (60 Characters)'
    };
}

sub buglist_column_joins {
    my ($self, $args) = @_;
    my $joins = $args->{column_joins};
    # 1. get latest comment for each bug
    # 2. then get the text / shortened text
    $joins->{last_comment} = {
        table => '(SELECT t1.bug_id, t1.thetext as lastcomment,'
                . ' substring(t1.thetext,1,60) as lastcomment60'
                . ' FROM longdescs as t1'
                . ' right join ('
                    . ' select bug_id, max(comment_id) as comment_id'
                    . ' from longdescs group by bug_id'
                . ' ) as t2 on t1.comment_id = t2.comment_id'
                . ')',
        as => 'last_comment_tbl',
        join => 'INNER'
    };
    # same join
    $joins->{last_comment_60} = $joins->{last_comment};
}

__PACKAGE__->NAME;