function gb = groupedBoxchart(group, colorGroup, value, P, B)
% grouped boxchart

arguments
    group
    colorGroup
    value
    P.Distance          (1,1)                               = 1.5;
    P.Shading           matlab.lang.OnOffSwitchState        = "on";
    P.ShadeColor                                            = "#cccccc";
    P.BoxColorList                                            = [];
    P.LabelLocation     string {mustBeMember( ...
                                P.LabelLocation, ...
                                ["bottom","top"])}          = "bottom";
    B.LineWidth         (1,1)                               = 1;
    B.BoxWidth          (1,1)                               = 0.5;
    B.MarkerStyle       (1,1)                               = "o";
    B.JitterOutliers    matlab.lang.OnOffSwitchState        = "off";
    B.Notch             matlab.lang.OnOffSwitchState        = "off";
    B.Orientation       string {mustBeMember( ...
                                B.Orientation, ...
                                ["vertical","horizontal"])} = "vertical";
end

% check input arguments
if numel(group)~=numel(colorGroup)||numel(group)~=numel(value)
    error("The number of elements in the 'group', 'colorGroup', and 'value'must match.")
end

% process input arguments
group       = group(:);
colorGroup  = colorGroup(:);
value       = value(:);
d           = P.Distance-1;
Bcell       = namedargs2cell(B);
if isstring(P.BoxColorList); P.BoxColorList = P.BoxColorList(:); end

% convert group to index
xgroupcat     = unique(group,"stable");
Nxgroup       = numel(xgroupcat);
[xgroupidx,~] = find(group'==xgroupcat);
cgroupcat     = unique(colorGroup,"stable");
Nc            = numel(cgroupcat);
[cgroupidx,~] = find((colorGroup'==cgroupcat));

% cla if hold is off
holdstate = ishold;
if ~holdstate
    cla reset;
end
hold on;

% visualize each color group
for n   = 1:Nc
    idx   = cgroupidx==n;
    xi    = xgroupidx(idx);
    ci    = cgroupidx(idx);
    y     = value(idx);

    opt = {};
    if ~isempty(P.BoxColorList)
        opt{end+1} = "BoxFaceColor";
        opt{end+1} = P.BoxColorList(n,:);
        opt{end+1} = "MarkerColor";
        opt{end+1} = P.BoxColorList(n,:);
    end

    gb(n) = boxchart((ci-1)+(xi-1)*(Nc+d),y, ...
        "DisplayName" ,string(cgroupcat(n)), ...
        opt{:},Bcell{:});
end

% restore hold state
if ~holdstate
    hold off;
end

% shade
if P.Shading
    sp  = (0:(Nc+d):(Nxgroup)*(Nc+d))'-(d+1)/2;
    sp  = sp(2:end);
    nsp = numel(sp);
    sp  = sp(1:nsp-mod(nsp,2));
    tv  = (0:(Nc+d):(Nxgroup-1)*(Nc+d))+(Nc-1)/2;
    
    if strcmp(B.Orientation,"horizontal")
    reg = yregion(reshape(sp,2,[]),"FaceColor",P.ShadeColor);
    yticks(tv);
    yticklabels(xgroupcat)
    else
    reg = xregion(reshape(sp,2,[]),"FaceColor",P.ShadeColor);
    xticks(tv);
    xticklabels(xgroupcat)
    set(gca,"XAxisLocation",P.LabelLocation);
    end
    for i = 1:numel(reg)
        reg(i).Annotation.LegendInformation.IconDisplayStyle = "off";
    end
end

% lim
lim = [-(d+1)/2 Nxgroup*(Nc+d)-(d+1)/2];
if strcmp(B.Orientation,"horizontal")
    ylim(lim)
else
    xlim(lim)
end

% box
box on
end