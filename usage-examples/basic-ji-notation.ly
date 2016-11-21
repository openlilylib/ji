%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% This file is part of openLilyLib,                                           %
%                      ===========                                            %
% the community library project for GNU LilyPond                              %
% (https://github.com/openlilylib)                                            %
%                                                                             %
% Library: ji                                                                 %
%          ==                                                                 %
%                                                                             %
% openLilyLib is free software: you can redistribute it and/or modify         %
% it under the terms of the GNU General Public License as published by        %
% the Free Software Foundation, either version 3 of the License, or           %
% (at your option) any later version.                                         %
%                                                                             %
% openLilyLib is distributed in the hope that it will be useful,              %
% but WITHOUT ANY WARRANTY; without even the implied warranty of              %
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               %
% GNU General Public License for more details.                                %
%                                                                             %
% You should have received a copy of the GNU General Public License           %
% along with openLilyLib. If not, see <http://www.gnu.org/licenses/>.         %
%                                                                             %
% openLilyLib is maintained by Urs Liska, ul@openlilylib.org                  %
% and others.                                                                 %
%       Copyright Urs Liska, 2016                                             %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\version "2.19.50"

\header {
  title = "Just Intonation"
  subtitle = "Notation with openLilyLib/ji"
}

% Activate the Just Intonation package
\include "ji/package.ily"

\markup \vspace #1
\markup "Ratios over middle c, printing cent deviation"

\setOption ji.show.cent ##t
{
  \jiNote 1 7/4
  \jiNote 3/2
  \jiNote 4/3
  \jiNote 5/4
}

\markup "Occasionally changing fundamental"
{
  \jiNote a, 1 5/1
  \jiNote 7/1
  \jiNote e, 1 5/1
  \jiNote 7/1
}

\markup "Changing fundamental with each note"
{
  \jiNote c, 1 4/1
  \jiNote bes,, 5/1
  \jiNote a,, 6/1
  \jiNote g,, 7/1
}

\markup "Displaying ratio instead of cents (fixed fundamental)"
\setOption ji.show.ratio ##t
\setOption ji.show.cent ##f
{
  \jiFundamental c,
  \jiNote 1 5/1
  \jiNote 6/1
  \jiNote 7/1
  \jiNote 8/1
}

\markup "Displaying ratio instead of cents (changing fundamental)"
{
  \jiNote g, 1 5/1
  \jiNote e, 6/1
  \jiNote cis, 7/1
  \jiNote b,, 8/1
}

\markup "Displaying fundamental instead of resulting pitch"
\markup "(same result as previous example)"
\setOption ji.show.notehead ##f
\setOption ji.show.fundamental ##t
{
  \clef bass
  \jiNote g, 1 5/1
  \jiNote e, 6/1
  \jiNote cis, 7/1
  \jiNote b,, 8/1
}

\markup "Displaying fundamental and result, one one or two staves"

% Activate some logic to automatically print on two staves
\useCrossStaff

\score {
  <<
    \new PianoStaff <<
      % In order to print on two staves we are responsible ourselves to provide
      % an upper staff and to keep it alive. This limitation may be removed in the
      % future but for now it is necessary.
      % The name is pre-configured in the ji package but can be changed with
      % \setOption ji.conf.cross-stuff.upper-name
      \new Staff = "ji-upper" {
        s1*2
      }

      \new Staff = "lower"  {
        \clef bass
        % Switch display of result on again
        % (has been removed for the previous example)
        \setOption ji.show.notehead ##t
        % switch on cent display (ratio is already on)
        \setOption ji.show.cent ##t
        % configure the style of the notehead
        % (not discussed in the paper)
        \setOption ji.show.notehead-style #'harmonic
        \jiNote c, 2 7/1

        \setOption ji.show.ratio ##f
        \jiNote 4 6/1

        \setOption ji.show.ratio ##t
        \setOption ji.show.cent ##f

        % Switch off cross-staff: resulting pitch will be displayed as a chord
        % on the same staff as the fundamental
        \setOption ji.conf.use-cross-staff ##f
        \jiNote 5/1

        \change Staff = "ji-upper"

        \jiNote c' 2 7/4
        \setOption ji.show.cent ##t
        \setOption ji.show.ratio ##f
        \jiNote d' 3/2
      }
    >>
  >>
}

% Page formatting, align markup with staff
\paper {
  indent =0
}
