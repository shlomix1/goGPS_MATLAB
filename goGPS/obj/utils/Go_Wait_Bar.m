%   CLASS Go_Wait_Bar
% =========================================================================
%
% DESCRIPTION
%   Class to show and manage a waitbar
%
% EXAMPLE
%   goWB = goWaitBar(10);
%   goWB.go();
%
%
% LIST of METHODS
%
%  GENERIC ------------------------------------------------------------
%
%   init(this, nSteps, msg)  Init the waitbar (and display it
%   close(this)              Close the window
%
%  DISPLAY ------------------------------------------------------------
%
%   go(this, step)           Just update the waitbar
%
%   goMsg(this, step)        Update the waitbar and accept a message to
%                           display within the window
%
%   goTime(this, step)       Update the waitbar and estimate the remaining
%                           computational time supposing a linear trend
%
%   titleUpdate(this, msg)   Change the title of the waitbar
%
% FOR A FULL LIST OF CONSTANTs and METHODS use doc Go_Wait_Bar

%--- * --. --- --. .--. ... * ---------------------------------------------
%               ___ ___ ___
%     __ _ ___ / __| _ | __
%    / _` / _ \ (_ |  _|__ \
%    \__, \___/\___|_| |___/
%    |___/                    v 0.5.1 beta 2
%
%--------------------------------------------------------------------------
%  Copyright (C) 2009-2017 Mirko Reguzzoni, Eugenio Realini
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti, ...
%  A list of all the historical goGPS contributors is in CREDITS.nfo
%--------------------------------------------------------------------------
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%--------------------------------------------------------------------------
% 01100111 01101111 01000111 01010000 01010011
%--------------------------------------------------------------------------

classdef Go_Wait_Bar < handle

    properties (Constant, GetAccess = 'private')
        MAX_BAR_LEN = 54;               % Dimension of the text bar
        DEL = char(ones(1,250)) * 8;    % array of /b, used to erase part of the text bar
        SPC = char(ones(1,250)) * 32;   % array of /s, used to fill the text bar
    end

    properties (GetAccess = 'public', SetAccess = 'public')
        type = 0;       % 0 means text, 1 means GUI, 5 both
        h = [];         % handle of the waitbar
        ext_h = [];     % extendend handles to the waitbar
        t0 = 0;         % start time of process
        nSteps = 1;     % number of step of the bar
        lastStep = 0;   % Last step done
        title = '';     % Title of the window
        msg = 'Please wait...'; % Message to display on the waitbar
        textBar = '[]'; % Text Bar
        bar_len = 2;    % Length of the latest text bar
    end

    methods (Access = 'private')

        % Creator
        function this = Go_Wait_Bar(nSteps, msg, type)
            % Creator
            if (nargin >= 1)
                this.nSteps = nSteps;
                this.lastStep = 0;
            end
            if (nargin >= 2)
                this.msg = msg;
            end
            if (nargin >= 3)
                this.type = type;
            end
        end

        function getNewBar(this, title)
            % Build a new graphic bar
            if (this.type == 1) ||  (this.type == 5)
                if verLessThan('matlab', 'R2015a')
                    try
                        delete(this.h);
                        this.h = waitbar(0, this.msg, 'Visible', 'off');
                    catch
                        %handle is not valid, or empty
                    end
                else
                    if isempty(this.h) || (~isvalid(this.h))
                        delete(this.h);
                        this.h = waitbar(0, this.msg, 'Visible', 'off');
                    end
                end
                this.ext_h = getappdata(this.h,'TMWWaitbar_handles');
                if (isunix())
                    this.ext_h.axesTitle.FontSize = 13;
                else
                    this.ext_h.axesTitle.FontSize = 10;
                end
                this.ext_h.axesTitle.Position(2) = 1.5;
                if nargin == 2
                    this.title = title;
                    this.setTitle(title);
                end
                this.h.Visible = 'on';
                drawnow;
            end
        end

        function getNewTextBar(this, title)
            % Build a new text bar
            if (this.type == 0) ||  (this.type == 5)
                if nargin == 2
                    this.title = title;
                    fprintf('%s', title);
                end
                this.textBar = this.getTextBar();
                txt = sprintf(' %s\n%s\n', this.msg, this.textBar);
                fprintf('\n%s', txt);
                this.bar_len = length(txt);
            end
        end

        function bar = getTextBar(this)
            % Get the standard text bar
            bar = sprintf('%3d%% [%s]', round(this.lastStep / this.nSteps * 100), this.SPC(1:this.MAX_BAR_LEN));
            last = round(this.lastStep / this.nSteps * this.MAX_BAR_LEN);
            if (last > 0)
                bar((1:last) + 6) = '=';
                if (last < this.MAX_BAR_LEN)
                    bar(last + 6) = '>';
                end
            end
        end

        function setMsg(this, msg)
            % Set a Message on top of the bar
            if (this.type == 1) ||  (this.type == 5)
                this.ext_h.axesTitle.String = msg;
            end
        end
    end

    methods (Static)
        function this = getInstance(nSteps, msg, type)
            % Implementation for a Singleton Class
            persistent unique_instance_waitbar__
            if isempty(unique_instance_waitbar__)
                switch (nargin)
                    case 0, this = Go_Wait_Bar();
                    case 1, this = Go_Wait_Bar(nSteps);
                    case 2, this = Go_Wait_Bar(nSteps, msg);
                    otherwise, this = Go_Wait_Bar(nSteps, msg, type);
                end
                unique_instance_waitbar__ = this;
            else
                this = unique_instance_waitbar__;
                if (nargin >= 3)
                    this.type = type;
                end
                if (nargin >= 1)
                    this.nSteps = nSteps;
                    this.lastStep = 0;
                end
                if (nargin >= 2)
                    this.msg = msg;
                    if (this.type == 1) ||  (this.type == 5)
                        if verLessThan('matlab', 'R2015a')
                            try
                                this.setMsg(msg);
                            catch
                                %handle is not valid, or empty
                            end
                        else
                            if not(isempty(this.h)) && (isvalid(this.h))
                                this.setMsg(msg);
                            end
                        end
                    end
                end
            end
        end
    end

    methods

        % Create a new window or plot the first bar
        function createNewBar(this, title, type)
            this.lastStep = 0;
            this.t0 = tic;
            % Create the window or plot the first bar
            if (nargin == 3)
                this.type = type;
            end
            if (nargin >= 2)
                this.getNewBar(title)
                this.getNewTextBar(title);
            else
                this.getNewBar()
                this.getNewTextBar();
            end
        end

        % Create the window or plot the text bar
        function createBar(this, title, type)
            % Create the window or plot the first bar
            if (nargin == 3)
                this.type = type;
            end
            if (nargin >= 2)
                this.getNewBar(title)
                this.getNewTextBar(title);
            else
                this.getNewBar()
                this.getNewTextBar();
            end
        end

        % Just update the waitbar
        function go(this,step)
            % Just update the waitbar
            if nargin == 2
                this.lastStep = min(this.nSteps, step);
            else
                this.lastStep = min(this.lastStep + 1,this.nSteps);
            end

            if (this.type == 1) ||  (this.type == 5)
                this.ext_h.progressbar.Value = this.lastStep / this.nSteps * this.ext_h.progressbar.Maximum;
                %drawnow limitrate;
            end
            if (this.type == 0) ||  (this.type == 5)
                this.textBar = this.getTextBar();
                %txt = sprintf(' %s\n %s\n%s\n', this.title, this.msg, this.textBar);
                txt = sprintf(' %s\n%s\n', this.msg, this.textBar);
                fprintf('%s%s', this.DEL(1:this.bar_len), txt);
                this.bar_len = length(txt);
            end

        end

        % Update the waitbar and accept a message to display within the window
        function goMsg(this, step, msg)
            % Update the waitbar and accept a message to display within the window
            if nargin == 3
                this.lastStep = min(this.nSteps, step);
            else
                msg = step;
                this.lastStep = min(this.lastStep + 1,this.nSteps);
            end
            this.msg = msg;

            % if graphic bar
            if (this.type == 1) ||  (this.type == 5)
                this.ext_h.progressbar.Value = this.lastStep / this.nSteps * this.ext_h.progressbar.Maximum;
                this.ext_h.axesTitle.String = this.msg;
                %drawnow limitrate;
            end

            %if text bar
            if (this.type == 0) ||  (this.type == 5)
                this.textBar = this.getTextBar();
                %txt = sprintf(' %s\n %s\n%s\n', this.title, this.msg, this.textBar);
                txt = sprintf(' %s\n%s\n', this.msg, this.textBar);
                fprintf('%s%s', this.DEL(1:this.bar_len), txt);
                this.bar_len = length(txt);
            end
        end

        % Update the waitbar and estimate the remaining computational time supposing a linear trend
        function goTime(this,step)
            % Update the waitbar and estimate the remaining computational time supposing a linear trend
            if nargin == 2
                this.lastStep = min(this.nSteps, step);
            else
                this.lastStep = min(this.lastStep + 1,this.nSteps);
            end
            % Elapsed time:
            t1= toc(this.t0);
            e_hh = floor(t1 / 3600);
            e_mm = floor((t1 - e_hh * 3600) / 60);
            e_ss = (t1 - e_hh * 3600 - e_mm * 60);
            %elapsedTime = sprintf('%02d:%02d:%04.1f', hh, mm, ss);
            % Remaining Time
            t1 = t1 / this.lastStep * (this.nSteps - this.lastStep);
            r_hh = floor(t1 / 3600);
            r_mm = floor((t1 - r_hh * 3600) / 60);
            r_ss = (t1 - r_hh * 3600 - r_mm * 60);
            %remainingTime = sprintf('%02d:%02d:%04.1f', hh, mm, ss);

            this.msg = sprintf(' Elapsed time                %02d:%02d:%04.1f\n Remaining time            %02d:%02d:%04.1f', e_hh, e_mm, e_ss, r_hh, r_mm, r_ss);

            % if graphic bar
            if (this.type == 1) ||  (this.type == 5)
                this.ext_h.progressbar.Value = this.lastStep / this.nSteps * this.ext_h.progressbar.Maximum;
                if (this.ext_h.axesTitle.Position(2) ~= 1.25)
                    %this.ext_h.axesTitle.FontName = 'Courier';
                    %this.ext_h.axesTitle.FontWeight = 'bold';
                    this.ext_h.axesTitle.Position(2) = 1.25;
                end
                this.ext_h.axesTitle.String = this.msg;
                %drawnow limitrate;
            end

            %if text bar
            if (this.type == 0) ||  (this.type == 5)
                this.textBar = this.getTextBar();
                %txt = sprintf(' %s\n%s\n%s\n', this.title, this.msg([1:13 16:end]), this.textBar);
                txt = sprintf('%s%s\n%s\n', this.DEL(1:this.bar_len), this.msg([1:13 16:end]), this.textBar);
                fprintf('%s', txt);
                this.bar_len = length(txt) - this.bar_len;
            end
        end

        % Set the max value accepted by the bar ( == 100%)
        function setBarLen(this, nSteps)
            % Set output type: 0 means text, 1 means GUI, 5 both
            this.nSteps = nSteps;
            this.lastStep = min(this.lastStep, nSteps);
        end

        % Set output type: 0 means text, 1 means GUI, 5 both
        function setOutputType(this, type)
            % Set output type: 0 means text, 1 means GUI, 5 both
            this.type = type;
            if verLessThan('matlab', 'R2015a')
                try
                    delete (this.h)
                catch
                    %handle is not valid, or empty
                end
            else
                if (type == 0) && (~isempty(this.h)) && (isvalid(this.h))
                    delete (this.h)
                end
            end
        end

        % Change the title of the waitbar
        function setTitle(this, msg)
            % Change the title of the waitbar
            this.title = msg;
            if verLessThan('matlab', 'R2015a')
                try
                    this.h.Name = msg;
                catch
                    %handle is not valid, or empty
                end
            else
                if ~isempty(this.h) && (isvalid(this.h))
                    this.h.Name = msg;
                end
            end
        end

        % Change the title of the waitbar (alias to setTitle - legacy implementation)
        function titleUpdate(this, msg)
            % Change the title of the waitbar (alias to setTitle - legacy implementation)
            this.setTitle(msg);
        end

        % Shift the waitbar downward (e.g. to make room for processing plots)
        function shiftDown(this, shf)
            % Shift the waitbar downward (e.g. to make room for processing plots)
            if (nargin < 2)
                shf = 120;
            end
            pos = this.h.Position;
            if (pos(2) > shf + pos(4))
                pos(2) = pos(2) - shf;
            end
            this.h.Position = pos;
        end

        % Close the window
        function close(this)
            % Close the window
            delete(this.h);
        end
    end

    methods (Static)
        function test(type)
            % Tester function
            if nargin == 0
                type = 5;
            end
            profile on
            nMax = 10000;
            b = Go_Wait_Bar.getInstance(nMax,'Whats''up!',type);

            fprintf('\n\nStarting test\n');
            t0 = tic;
            tic;
            b.createNewBar('Simple Bar...');
            for i = 1 : nMax
                b.go(i);
            end
            toc;
            tic;
            fprintf('\n');
            b.createNewBar('Bar...');
            for i = 1 : nMax
                b.goMsg(i,sprintf('with a message %03d', i));
            end
            toc;
            tic;
            fprintf('\n');
            b.createNewBar('Bar whit timings...');
            for i = 1 : nMax
                b.goTime(i);
            end
            toc;
            fprintf('\n Test completec');

            toc(t0);
            profile off
            profile viewer
        end

        function testOld()
            % Tester function of the old object
            nMax = 5000;
            bOld = goWaitBar(nMax,'Whats''up!');

            fprintf('\n\nStarting test\n');
            t0 = tic;
            tic;
            for i = 1 : nMax
                bOld.go(i);
                %b.goMsg(i,num2str(i,'%03d'));
                %b.goTime(i);
            end
            toc;
            tic;
            fprintf('\n');
            for i = 1 : nMax
                bOld.goMsg(i,sprintf('with a message %03d', i));
            end
            toc;
            tic;
            fprintf('\n');
            for i = 1 : nMax
                bOld.goTime(i);
            end
            toc;
            fprintf('\n Test completec');

            toc(t0);
        end
    end
end
