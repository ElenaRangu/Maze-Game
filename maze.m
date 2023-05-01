function thyme = maze(row,col,pattern)
% model - aleatoriu (r), vertical (v), orizontal (h), tablă de șah (c), spirală (e), explozie (b)
% intersecție (id), rândul fizic (rr) și coloana (cc)



rand('state',sum(100*clock))

[cc,rr]=meshgrid(15:col,15:row);
state = reshape([1:row*col],row,col); % se identifica regiunile conectate
id = reshape([1:row*col],row,col); % id de identificare ale intersectiti labirintului
% crearea pointerilor
ptr_left = zeros(size(id));
ptr_up = zeros(size(id));
ptr_right = zeros(size(id));
ptr_down = zeros(size(id));

ptr_left(:,2:size(id,2)) = id(:,1:size(id,2)-1);
ptr_up(2:size(id,1),:) = id(1:size(id,1)-1,:);
ptr_right(:,1:size(id,2)-1) = id(:,2:size(id,2));
ptr_down(1:size(id,1)-1,:) = id(2:size(id,1),:);

% sortare entitati
the_maze = cat(2,reshape(id,row*col,1),reshape(rr,row*col,1),reshape(cc,row*col,1),reshape(state,row*col,1),...
    reshape(ptr_left,row*col,1),reshape(ptr_up,row*col,1),reshape(ptr_right,row*col,1),reshape(ptr_down,row*col,1)  );

the_maze = sortrows(the_maze);

id=the_maze(:,1);
rr=the_maze(:,2);
cc=the_maze(:,3);
state=the_maze(:,4);
ptr_left=the_maze(:,5);
ptr_up=the_maze(:,6);
ptr_right=the_maze(:,7);
ptr_down=the_maze(:,8);
clear the_maze;

% crearea unui labirint random
[state, ptr_left, ptr_up, ptr_right, ptr_down]=...
    make_pattern(row,col,pattern,id, rr, cc, state, ptr_left, ptr_up, ptr_right, ptr_down);

% afisare maze
h=figure('KeyPressFcn',@move_spot,'color','white');
show_maze(row, col, rr, cc, ptr_left, ptr_up, ptr_right, ptr_down,h);

% start play
cursor_pos=[1,1];
current_id=1;
figure(h)
text(cursor_pos(1),cursor_pos(2),'\heartsuit','HorizontalAlignment','Center','color','r');
set(gcf,'Units','normalized');
set(gcf,'position',[0 0 1 .91]);
tic

% se apasa tastele sus-jos, dreapta-stanga
while ~all(cursor_pos == [col,row])
    waitfor(gcf,'CurrentCharacter')
    set(gcf,'CurrentCharacter','~') 
   
    % cheia este actualizata de move_spot
    switch double(key(1))
        case 108 % stanga
            if ptr_left(current_id)<0 % verificare daca se poate trece
                current_id=-ptr_left(current_id);
                text(cursor_pos(1),cursor_pos(2),'\heartsuit','HorizontalAlignment','Center','color',[.8,.8,.8]); % heartsuit- simbolul cu care rezolvi maze-ul, orientare, culoare
                cursor_pos(1)=cursor_pos(1)-1;
                text(cursor_pos(1),cursor_pos(2),'\heartsuit','HorizontalAlignment','Center','color','r');
            end
        case 114 % dreapta
            if ptr_right(current_id)<0  % verificare daca se poate trece
                current_id=-ptr_right(current_id);
                text(cursor_pos(1),cursor_pos(2),'\heartsuit','HorizontalAlignment','Center','color',[.8,.8,.8]);
                cursor_pos(1)=cursor_pos(1)+1;
                text(cursor_pos(1),cursor_pos(2),'\heartsuit','HorizontalAlignment','Center','color','r');
            end
        case 117 % sus
            if ptr_up(current_id)<0  % verificare daca se poate trece
                current_id=-ptr_up(current_id);
                text(cursor_pos(1),cursor_pos(2),'\heartsuit','HorizontalAlignment','Center','color',[.8,.8,.8]);
                cursor_pos(2)=cursor_pos(2)-1;
                text(cursor_pos(1),cursor_pos(2),'\heartsuit','HorizontalAlignment','Center','color','r');
            end
        case 100 % jos
            if ptr_down(current_id)<0  % verificare daca se poate trece
                current_id=-ptr_down(current_id);
                text(cursor_pos(1),cursor_pos(2),'\heartsuit','HorizontalAlignment','Center','color',[.8,.8,.8]);
                cursor_pos(2)=cursor_pos(2)+1;
                text(cursor_pos(1),cursor_pos(2),'\heartsuit','HorizontalAlignment','Center','color','r');
            end

        otherwise
    end

end

thyme=toc;
title(cat(2,' Winning Time ',num2str(round(thyme*100)/100),'(sec)'),'FontSize',20)
return

function move_spot(src,evnt)
assignin('caller','key',evnt.Key)
return


function show_maze(row, col, rr, cc, ptr_left, ptr_up, ptr_right, ptr_down,h)
figure(h)
 line([.5,col+.5],[.5,.5]) % desenare chenar sus

line([.5,col+.5],[row+.5,row+.5]) % desenare chenar jos
line([.5,.5],[1.5,row+.5])% desenare chenar stanga
line([col+.5,col+.5],[.5,row-.5])% desenare chenar dreapta
for ii=1:length(ptr_right)
    if ptr_right(ii)>0 % trecere pe sus blocata
        line([cc(ii)+.5,cc(ii)+.5],[rr(ii)-.5,rr(ii)+.5]);
        hold on
    end
    if ptr_down(ii)>0 % trecere pe jos blocata
        line([cc(ii)-.5,cc(ii)+.5],[rr(ii)+.5,rr(ii)+.5]);
        hold on
    end
    
end
axis equal
axis([.5,col+.5,.5,row+.5])
axis off
set(gca,'YDir','reverse')
return




function [state, ptr_left, ptr_up, ptr_right, ptr_down]=make_pattern(row,col,pattern,id, rr, cc, state, ptr_left, ptr_up, ptr_right, ptr_down)

while max(state)>1 
    tid=ceil(col*row*rand(15,1));
    cityblock=cc(tid)+rr(tid); % get distanta de la start
    is_linked=(state(tid)==1); % Starea de pornire este în regiunea 1
    temp = sortrows(cat(2,tid,cityblock,is_linked),[3,2]); % sortare id uri
    tid = temp(1,1);
    
    
    switch upper(pattern) 
    case 'C' % principiul tabla de sah
        dir = ceil(8*rand);
        nb=3;
        block_size =  min([row,col])/nb;
        while block_size>12
            nb=nb+2;
            block_size =  min([row,col])/nb;
        end
        odd_even = (ceil(rr(tid)/block_size)*ceil(col/block_size) + ceil(cc(tid)/block_size));
        if odd_even/2 == floor(odd_even/2)
            if dir>6
                dir=4;
            end
            if dir>4
                dir=3;
            end
        else
            if dir>6
                dir=2;
            end
            if dir>4
                dir=1;
            end
        end
    case 'B' % burst
        dir = ceil(8*rand);
        if abs((rr(tid)-row/2))<abs((cc(tid)-col/2))
            if dir>6
                dir=4;
            end
            if dir>4
                dir=3;
            end
        else
            if dir>6
                dir=2;
            end
            if dir>4
                dir=1;
            end
        end
    case 'S' % spirala
        dir = ceil(8*rand);
        if abs((rr(tid)-row/2))>abs((cc(tid)-col/2))
            if dir>6
                dir=4;
            end
            if dir>4
                dir=3;
            end
        else
            if dir>6
                dir=2;
            end
            if dir>4
                dir=1;
            end
        end
    case 'V'
        dir = ceil(8*rand);
        if dir>6
            dir=4;
        end
        if dir>4
            dir=3;
        end
    case 'H'
        dir = ceil(8*rand);
        if dir>6
            dir=2;
        end
        if dir>4
            dir=1;
        end
        otherwise % aleatoriu
        dir = ceil(4*rand);
    end
    
   % după ce este găsit o forma pentru îndepărtarea peretelui, forma trebuie să promoveze
     % doua conditii. 1) nu este un perete exterior 2) regiunile pe fiecare parte a peretelui a fost anterior neconectată. 
     % Dacă are succes perete este eliminat, stările conectate sunt actualizate la cea mai mică dintre
     % cele două stări, pointerii dintre intersecțiile conectate sunt
     % acum negativ.
     
    switch dir
    case -1
        
    case 1
        if ptr_left(tid)>0 & state(tid)~=state(ptr_left(tid))
            state( state==state(tid) | state==state(ptr_left(tid)) )=min([state(tid),state(ptr_left(tid))]);
            ptr_right(ptr_left(tid))=-ptr_right(ptr_left(tid));
            ptr_left(tid)=-ptr_left(tid);
        end
    case 2
        if ptr_right(tid)>0 & state(tid)~=state(ptr_right(tid))
            state( state==state(tid) | state==state(ptr_right(tid)) )=min([state(tid),state(ptr_right(tid))]);
            ptr_left(ptr_right(tid))=-ptr_left(ptr_right(tid));
            ptr_right(tid)=-ptr_right(tid);
        end
    case 3
        if ptr_up(tid)>0 & state(tid)~=state(ptr_up(tid))
            state( state==state(tid) | state==state(ptr_up(tid)) )=min([state(tid),state(ptr_up(tid))]);
            ptr_down(ptr_up(tid))=-ptr_down(ptr_up(tid));
            ptr_up(tid)=-ptr_up(tid);
        end
    case 4
        if ptr_down(tid)>0 & state(tid)~=state(ptr_down(tid))
            state( state==state(tid) | state==state(ptr_down(tid)) )=min([state(tid),state(ptr_down(tid))]);
            ptr_up(ptr_down(tid))=-ptr_up(ptr_down(tid));
            ptr_down(tid)=-ptr_down(tid);
        end
    otherwise
        dir
        error('quit')
    end
    
end
return