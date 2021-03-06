<!DOCTYPE html>
<meta charset='utf-8'>
<html>
    <head>
        <link href='/static/css/style.css' type='text/css' rel='stylesheet' />
        <script type='text/javascript' src='/static/js/jquery.min.js'></script>
    </head>
    <body>
        <script type='text/javascript'>
            function toggle_list(list_id) {
                var li_list = $('#' + list_id + ' li');

                if (li_list[0].style['display'] == 'none') {
                    li_list.show();
                    $('#' + list_id + '_link')[0].innerHTML = '-';
                } else {
                    li_list.hide();
                    $('#' + list_id + '_link')[0].innerHTML = '+';
                }
            }

            $(document).ready(function(){
                var update_name = function() {
                    if ($(this).val() != '') {
                        $(this).attr('name', $(this).val());
                    } else {
                        $(this).attr('name', '');
                    }
                }

                $(".wildcard").change(update_name);
                $(".wildcard").keydown(update_name);

                $('#add_field').click(function() {
                    $('#explicit_metrics').append("<li><input type='text' class='wildcard' /></li>");
                });

                var refresh_timeout = null;

                var filter = function() {
                    var value = $(this).val();
                    clearTimeout(refresh_timeout);
                    refresh_timeout = setTimeout( function() {
                        $(".components li").each( function() {
                            var item = $(this);
                            var chk = $("input", item)[0]
                            if(value == '' || item.html().match(value) || (chk && chk.checked)) {
                                item.show();
                            } else {
                                item.hide();
                            }
                        });
                    }, 300);
                }

                $(".filter").change(filter);
                $(".filter").keydown(filter);
            });

        </script>

        <%include file="login.mako" args="username='${username}'"/>
        % if 'error' in kwargs:
            <h2 class='error'>
            % if kwargs['error'] == 'no_title':
                You must specify a title
            % elif kwargs['error'] == 'no_fields':
                You must specify at least one field
            % elif kwargs['error'] == 'bad_wildcard_filter':
                Wildcards must contain a "|"
            % endif
            </h2>
        % endif
        <h2><a class='nav' href='/'>tf</a> :: edit graph</h2>
        <form action='/edit' method='post'>
            Title: <input type='text' size=30 name='title' value="${kwargs['title']}"/>
            <p>Timescale: <select name='timescale'>
            % for each_timescale in timescales:
                % if 'timescale' in kwargs and each_timescale == kwargs['timescale']:
                    <option selected value=${each_timescale}>${each_timescale}</option>
                % else:
                    <option value=${each_timescale}>${each_timescale}</option>
                % endif
            % endfor
            </select></p>
            <p>Graph Type: <select name='graph_type'>
            % for graph_type in graph_types:
                % if 'graph_type' in kwargs and graph_type == kwargs['graph_type']:
                    <option selected value=${graph_type}>${graph_type}</option>
                % elif 'graph_type' not in kwargs and graph_type == 'line':
                    <option selected value='line'>line</option>
                % else:
                    <option value=${graph_type}>${graph_type}</option>
                % endif
            % endfor
            </select></p>
            <input type='submit' value='save' />
            <ul>

            <li><b>Wildcard Items</b>
                <p>Type the name of the component and metric you want i.e. component|metric* or *|metric</p>
                <ul id='explicit_metrics'>
                    % for item in fields:
                        % if '*' in item:
                            <li><input type='text' name='${cgi.escape(item)}' value='${cgi.escape(item)}' class='wildcard' /></li>
                        % endif
                    % endfor

                    <li><input type='text' class='wildcard' /></li>
                </ul>
                <button id='add_field' type='button'>Add another field</button>
            </li>
            <br />

            <li><b>All Components</b>
                <p>Filter Metrics:<input type="text" class="filter" width=50></p>
                <ul>
                    % for component, metrics in data_sources.iteritems():
                        % if component in active_components:
                            <li><a id='${component}_link' href='javascript:void(0)' onClick="toggle_list('${component}')">-</a> ${component}</li>
                        % else:
                            <li><a id='${component}_link' href='javascript:void(0)' onClick="toggle_list('${component}')">+</a> ${component}</li>
                        % endif
                        <ul id='${component}' class="components">
                        % for metric in metrics:
                            % if component in active_components:
                                <li>
                            % else:
                                <li style='display: none;'>
                            % endif
                            % if '%s|%s' % (component, metric) in fields:
                                <input type='checkbox' name='${cgi.escape('%s|%s' % (component, metric))}' value='true' checked='checked'/> ${cgi.escape(metric)}
                            % else:
                                    <input type='checkbox' name='${cgi.escape('%s|%s' % (component, metric))}' value='true' /> ${cgi.escape(metric)}
                            % endif
                            </li>
                        % endfor
                        </ul>
                    % endfor
                </ul>
                </li>
            </ul>
            <br />
            <input type='submit' value='save' />
        </form>
    </body>
</html>
