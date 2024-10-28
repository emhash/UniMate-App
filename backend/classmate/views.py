from django.shortcuts import render, HttpResponse

def demohomepage(request):

    temp_demp_page = '''
    <style>
        body {
        font-family: Arial, sans-serif;
        text-align: center;
        margin: 50px;
        }
        h1 {
        color: #333;
        }
        ul {
        list-style: none;
        padding: 0;
        }
        li {
        margin: 10px 0;
        }
        a {
        text-decoration: none;
        color: #007bff;
        font-weight: bold;
        }
    </style>

    <body>
    <h1>API Links</h1>
    <ul>
        <li><a href="/api/users/">Get and Post Users</a></li>
        
        </ul>
    </body>
    '''
    return HttpResponse(temp_demp_page)

